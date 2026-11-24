// 저장소 관리자(자동 업데이트): 임시 폴더에 로컬 git 저장소를 만들어 clone·갱신을 확인한다(네트워크 없이)
#include <git2.h>

#include <filesystem>
#include <fstream>
#include <sstream>

#include "card_db.h"
#include "repo_manager.h"
#include "test.h"

namespace {

namespace fs = std::filesystem;

std::string read_all(const fs::path& p) {
  std::ifstream f(p, std::ios::binary);
  std::stringstream ss;
  ss << f.rdbuf();
  return ss.str();
}

// 원본 저장소에 파일 하나를 쓰고 커밋한다
bool commit_file(git_repository* repo, const fs::path& dir, const char* name, const std::string& text) {
  std::ofstream(dir / name, std::ios::binary) << text;
  git_index* idx = nullptr;
  git_oid tree_id{}, commit_id{};
  git_tree* tree = nullptr;
  git_signature* sig = nullptr;
  git_commit* parent = nullptr;
  bool ok = git_repository_index(&idx, repo) == 0 && git_index_add_bypath(idx, name) == 0 && git_index_write(idx) == 0 &&
            git_index_write_tree(&tree_id, idx) == 0 && git_tree_lookup(&tree, repo, &tree_id) == 0 &&
            git_signature_now(&sig, "test", "test@example.com") == 0;
  if (ok) {
    git_oid head{};
    const bool has_parent = git_reference_name_to_id(&head, repo, "HEAD") == 0 && git_commit_lookup(&parent, repo, &head) == 0;
    const git_commit* parents[] = {parent};
    ok = git_commit_create(&commit_id, repo, "HEAD", sig, sig, nullptr, "test", tree, has_parent ? 1 : 0, parents) == 0;
  }
  git_commit_free(parent);
  git_signature_free(sig);
  git_tree_free(tree);
  git_index_free(idx);
  return ok;
}

}  // namespace

TEST_CASE("repos: 저장소를 처음엔 받고, 원본이 바뀌면 갱신하고(로컬 수정은 덮음), 같으면 최신", "결정 2026-11-22: 자동 업데이트(CyanPro와 같음)") {
  git_libgit2_init();
  const fs::path root = fs::temp_directory_path() / "wx_repo_case";
  std::error_code ec;
  fs::remove_all(root, ec);
  const fs::path src = root / "src", dst = root / "dst";
  fs::create_directories(src, ec);
  git_repository* repo = nullptr;
  CHECK(git_repository_init(&repo, src.string().c_str(), 0) == 0);
  CHECK(commit_file(repo, src, "cards.txt", "v1"));

  wxframe::RepoConfig cfg;
  cfg.url = src.string();
  cfg.name = "검사 저장소";
  cfg.path = dst.string();
  auto r = wxframe::RepoManager::update_one(cfg);
  if (r.state != wxframe::RepoStatus::Done) std::printf("    %s\n", r.message.c_str());
  CHECK(r.state == wxframe::RepoStatus::Done && r.changed);
  CHECK(read_all(dst / "cards.txt") == "v1");

  // 원본이 바뀌면 받아 오고, 저장소 안의 로컬 수정은 덮어쓴다
  CHECK(commit_file(repo, src, "cards.txt", "v2"));
  std::ofstream(dst / "cards.txt", std::ios::binary) << "local edit";
  r = wxframe::RepoManager::update_one(cfg);
  if (r.state != wxframe::RepoStatus::Done) std::printf("    %s\n", r.message.c_str());
  CHECK(r.state == wxframe::RepoStatus::Done && r.changed);
  CHECK(read_all(dst / "cards.txt") == "v2");

  // 바뀐 게 없으면 최신
  r = wxframe::RepoManager::update_one(cfg);
  CHECK(r.state == wxframe::RepoStatus::Done && !r.changed && r.message == "최신");

  // 없는 저장소는 실패로 알린다
  wxframe::RepoConfig bad = cfg;
  bad.url = (root / "none").string();
  bad.path = (root / "bad").string();
  r = wxframe::RepoManager::update_one(bad);
  CHECK(r.state == wxframe::RepoStatus::Failed && !r.message.empty());

  git_repository_free(repo);
  git_libgit2_shutdown();
  fs::remove_all(root, ec);
}

TEST_CASE("repos: 설정 파일(config/configs.json)을 읽는다", "CyanPro configs.json 형식") {
  std::vector<wxframe::RepoConfig> repos;
  std::string url, err;
  CHECK(wxframe::load_repo_config(wxtest::data_dir() + "/config/configs.json", repos, url, err));
  CHECK(repos.size() >= 2);
  bool core = false;
  for (const auto& r : repos) core |= r.has_core;
  CHECK(core);
}

TEST_CASE("repos: repositories/ 밖을 가리키는 repo_path와 https가 아닌 주소는 건너뛴다", "점검 2026-11-24 #4-3") {
  for (const char* ok : {"./repositories/A", "repositories/A", "repositories/A/B"}) CHECK(wxframe::safe_repo_path(ok));
  for (const char* bad : {"", ".", "..", "repositories", "repositories/..", "repositories/../decks", "../repositories/A", "decks",
                          "C:/repositories/A", "/repositories/A", "C:repositories/A"})
    CHECK(!wxframe::safe_repo_path(bad));
  const fs::path file = fs::temp_directory_path() / "wx_repo_bad.json";
  std::ofstream(file, std::ios::binary) << R"({"repos":[
    {"url":"https://a/b","repo_path":"../x"},{"url":"http://a/b","repo_path":"repositories/x"},
    {"url":"https://a/b","repo_path":"repositories/ok"}]})";
  std::vector<wxframe::RepoConfig> repos;
  std::string url, err;
  CHECK(wxframe::load_repo_config(file.string(), repos, url, err));
  CHECK(repos.size() == 1 && repos[0].path == "repositories/ok" && !err.empty());
  fs::remove(file);
}

TEST_CASE("repos: 코어 DLL은 has_core 저장소에서만, configs.json 순서로", "지시 2026-11-23 #2") {
  const fs::path root = fs::temp_directory_path() / "wx_core_paths";
  std::error_code ec;
  fs::remove_all(root, ec);
  // a_orica(이름순으로 앞)·z_orica(이름순으로 뒤)는 코어 저장소가 아닌데 DLL이 들어 있다
  for (const char* name : {"a_orica", "core1", "core2", "z_orica", "core_empty"}) {
    fs::create_directories(root / name / "bin", ec);
    if (std::string(name) != "core_empty") std::ofstream(root / name / "bin" / "wxcore.dll") << "x";
  }
  auto repo = [&](const char* name, bool has_core) {
    wxframe::RepoConfig c;
    c.url = "x";
    c.name = name;
    c.path = (root / name).string();
    c.has_core = has_core;
    return c;
  };
  const auto paths = wxframe::repo_core_paths(
      {repo("a_orica", false), repo("core2", true), repo("core_empty", true), repo("core1", true), repo("z_orica", false)},
      "wxcore.dll");
  CHECK(paths.size() == 2);
  CHECK(paths.size() == 2 && fs::path(paths[0]) == (root / "core2" / "bin" / "wxcore.dll").lexically_normal());
  CHECK(paths.size() == 2 && fs::path(paths[1]) == (root / "core1" / "bin" / "wxcore.dll").lexically_normal());
  CHECK(wxframe::repo_core_paths({repo("a_orica", false), repo("z_orica", false)}, "wxcore.dll").empty());
  fs::remove_all(root, ec);
}
