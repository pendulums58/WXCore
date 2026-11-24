#include "repo_manager.h"

#include <git2.h>

#include <filesystem>
#include <fstream>
#include <sstream>

#include "card_db.h"
#include "json.h"

namespace wxframe {

namespace {

namespace fs = std::filesystem;

std::string git_message(const char* what) {
  const git_error* e = git_error_last();
  return std::string(what) + ": " + (e && e->message ? e->message : "알 수 없는 오류");
}

struct Progress {
  const std::atomic<bool>* stop;
  std::atomic<int>* percent;
};

int on_transfer(const git_indexer_progress* p, void* payload) {
  auto* pr = static_cast<Progress*>(payload);
  if (pr->percent && p->total_objects) pr->percent->store(static_cast<int>(p->received_objects * 100 / p->total_objects));
  return pr->stop && pr->stop->load() ? -1 : 0;  // 0이 아니면 받기를 멈춘다
}

// 원격의 기본 가지가 가리키는 커밋
bool remote_head(git_repository* repo, git_oid& out) {
  for (const char* ref : {"refs/remotes/origin/HEAD", "refs/remotes/origin/main", "refs/remotes/origin/master"})
    if (git_reference_name_to_id(&out, repo, ref) == 0) return true;
  return false;
}

}  // namespace

bool safe_repo_path(const std::string& path) {
  const fs::path p = fs::path(path).lexically_normal();
  if (p.empty() || p.has_root_path()) return false;
  auto it = p.begin();
  if (it == p.end() || *it != "repositories") return false;
  ++it;
  return it != p.end() && !it->empty() && *it != "." && *it != "..";
}

bool load_repo_config(const std::string& path, std::vector<RepoConfig>& repos, std::string& update_url, std::string& err) {
  std::ifstream f(path, std::ios::binary);
  if (!f) {
    err = path + ": 없음";
    return false;
  }
  std::stringstream ss;
  ss << f.rdbuf();
  wxtest::Json j;
  if (!wxtest::parse_json(ss.str(), j) || !j.obj()) {
    err = path + ": JSON 형식 오류";
    return false;
  }
  if (auto* u = j.get("update_url"); u && u->str()) update_url = *u->str();
  if (auto* list = j.get("repos"); list && list->arr())
    for (const auto& r : *list->arr()) {
      RepoConfig c;
      auto str = [&](const char* k) {
        const wxtest::Json* v = r.get(k);
        return v && v->str() ? *v->str() : std::string();
      };
      auto flag = [&](const char* k, bool def) {
        const wxtest::Json* v = r.get(k);
        return v && v->boolean() ? *v->boolean() : def;
      };
      c.url = str("url");
      c.name = str("repo_name");
      c.path = str("repo_path");
      c.has_core = flag("has_core", false);
      c.should_update = flag("should_update", true);
      if (c.name.empty()) c.name = c.url;
      if (c.url.empty() || c.path.empty()) continue;
      if (c.url.rfind("https://", 0) != 0 || !safe_repo_path(c.path)) {
        err = path + ": " + c.name + "은 건너뜀(주소는 https://, repo_path는 repositories/ 아래여야 한다)";
        continue;
      }
      repos.push_back(std::move(c));
    }
  return true;
}

std::vector<std::string> repo_core_paths(const std::vector<RepoConfig>& repos, const std::string& dll) {
  std::vector<std::string> out;
  for (const auto& r : repos) {
    if (!r.has_core) continue;
    fs::path p = fs::path(r.path) / "bin" / dll;
    if (p.is_relative()) p = fs::path(wxtest::data_dir()) / p;
    std::error_code ec;
    if (fs::is_regular_file(p, ec)) out.push_back(p.lexically_normal().string());
  }
  return out;
}

RepoStatus RepoManager::update_one(const RepoConfig& cfg, const std::atomic<bool>* stop, std::atomic<int>* percent) {
  RepoStatus st;
  st.name = cfg.name;
  st.has_core = cfg.has_core;
  git_libgit2_init();
  fs::path dir = cfg.path;
  if (dir.is_relative()) dir = fs::path(wxtest::data_dir()) / dir;
  Progress pr{stop, percent};
  git_repository* repo = nullptr;
  if (!fs::exists(dir / ".git")) {
    // 처음: clone
    std::error_code ec;
    fs::remove_all(dir, ec);  // 반쯤 받다 만 폴더
    fs::create_directories(dir.parent_path(), ec);
    git_clone_options opts = GIT_CLONE_OPTIONS_INIT;
    opts.fetch_opts.callbacks.transfer_progress = on_transfer;
    opts.fetch_opts.callbacks.payload = &pr;
    if (git_clone(&repo, cfg.url.c_str(), dir.string().c_str(), &opts) != 0) {
      st.state = RepoStatus::Failed;
      st.message = git_message("받기 실패");
    } else {
      st.state = RepoStatus::Done;
      st.changed = true;
      st.message = "새로 받음";
    }
  } else if (git_repository_open(&repo, dir.string().c_str()) != 0) {
    st.state = RepoStatus::Failed;
    st.message = git_message("저장소를 못 엶");
  } else {
    // 있으면: fetch 뒤 원격 최신으로(로컬 수정은 덮어쓴다)
    git_remote* remote = nullptr;
    git_fetch_options fo = GIT_FETCH_OPTIONS_INIT;
    fo.callbacks.transfer_progress = on_transfer;
    fo.callbacks.payload = &pr;
    if (git_remote_lookup(&remote, repo, "origin") != 0 || git_remote_fetch(remote, nullptr, &fo, nullptr) != 0) {
      st.state = RepoStatus::Failed;
      st.message = git_message("확인 실패");
    } else {
      git_oid target{}, head{};
      const bool has_head = git_reference_name_to_id(&head, repo, "HEAD") == 0;
      if (!remote_head(repo, target)) {
        st.state = RepoStatus::Failed;
        st.message = "원격 기본 가지를 못 찾음";
      } else if (has_head && git_oid_equal(&target, &head)) {
        st.state = RepoStatus::Done;
        st.message = "최신";
      } else {
        git_object* obj = nullptr;
        if (git_object_lookup(&obj, repo, &target, GIT_OBJECT_COMMIT) != 0 ||
            git_reset(repo, obj, GIT_RESET_HARD, nullptr) != 0) {
          st.state = RepoStatus::Failed;
          st.message = git_message("갱신 실패");
        } else {
          st.state = RepoStatus::Done;
          st.changed = true;
          st.message = "갱신함";
        }
        git_object_free(obj);
      }
    }
    git_remote_free(remote);
  }
  git_repository_free(repo);
  git_libgit2_shutdown();
  return st;
}

RepoManager::~RepoManager() {
  stop_ = true;
  if (worker_.joinable()) worker_.join();
}

void RepoManager::start(std::vector<RepoConfig> repos) {
  if (running_) return;
  if (worker_.joinable()) worker_.join();
  {
    std::lock_guard<std::mutex> lock(mu_);
    status_.clear();
    for (const auto& r : repos) {
      RepoStatus s;
      s.name = r.name;
      s.has_core = r.has_core;
      s.message = r.should_update ? "기다리는 중" : "받지 않음(설정)";
      if (!r.should_update) s.state = RepoStatus::Done;
      status_.push_back(s);
    }
  }
  started_ = true;
  running_ = true;
  stop_ = false;
  worker_ = std::thread(&RepoManager::run, this, std::move(repos));
}

void RepoManager::run(std::vector<RepoConfig> repos) {
  for (size_t i = 0; i < repos.size() && !stop_; ++i) {
    if (!repos[i].should_update) continue;
    {
      std::lock_guard<std::mutex> lock(mu_);
      current_ = i;
      status_[i].state = RepoStatus::Working;
      status_[i].message = "받는 중";
    }
    percent_ = 0;
    RepoStatus r = update_one(repos[i], &stop_, &percent_);
    std::lock_guard<std::mutex> lock(mu_);
    status_[i] = std::move(r);
  }
  running_ = false;
}

std::vector<RepoStatus> RepoManager::status() const {
  std::lock_guard<std::mutex> lock(mu_);
  std::vector<RepoStatus> out = status_;
  if (running_ && current_ < out.size()) out[current_].percent = percent_;
  return out;
}

}  // namespace wxframe
