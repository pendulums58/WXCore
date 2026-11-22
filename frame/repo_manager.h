#pragma once
// 저장소 관리자(libgit2, CyanPro/EDOPro의 repo_manager와 같은 역할).
// config/configs.json의 repos 목록대로 켤 때마다 저장소를 받는다: 없으면 clone, 있으면 fetch 뒤 원격 최신으로 맞춘다
// (저장소 안의 로컬 수정은 덮어쓴다. 개인 작업물은 expansions/에 둔다).
// 받는 일은 작업 스레드에서 하고, 화면은 status()로 진행을 읽는다. 코어는 건드리지 않는다(코어의 단일 스레드 규칙과 무관).
#include <atomic>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

namespace wxframe {

struct RepoConfig {
  std::string url, name, path;  // path: 데이터 폴더 기준(./repositories/○○)
  bool has_core = false;        // bin/에 코어 DLL이 들어 있다(다시 시작해야 적용)
  bool should_update = true;
};

struct RepoStatus {
  enum State { Waiting, Working, Done, Failed } state = Waiting;
  std::string name, message;
  int percent = 0;
  bool changed = false;  // 이번에 새로 받았거나 바뀌었다
  bool has_core = false;
};

// configs.json 읽기. update_url은 클라이언트 업데이터용(U3)
bool load_repo_config(const std::string& path, std::vector<RepoConfig>& repos, std::string& update_url, std::string& err);

class RepoManager {
 public:
  ~RepoManager();
  void start(std::vector<RepoConfig> repos);  // 작업 스레드에서 차례로 받는다
  // 검사용: 지금 스레드에서 하나를 받는다
  static RepoStatus update_one(const RepoConfig& repo, const std::atomic<bool>* stop = nullptr,
                               std::atomic<int>* percent = nullptr);
  std::vector<RepoStatus> status() const;
  bool running() const { return running_; }
  bool finished() const { return started_ && !running_; }

 private:
  void run(std::vector<RepoConfig> repos);

  mutable std::mutex mu_;
  std::vector<RepoStatus> status_;
  std::thread worker_;
  std::atomic<bool> running_{false}, stop_{false};
  bool started_ = false;
  std::atomic<int> percent_{0};
  size_t current_ = 0;
};

}  // namespace wxframe
