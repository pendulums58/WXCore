#pragma once
// 클라이언트 업데이터(EDOPro의 ClientUpdater와 같은 역할, libcurl + miniz).
// update_url의 update.json: {"version": "0.2.0", "files": [{"name": "...zip", "url": "...", "md5": "..."}]}
// 지금 버전보다 새로우면 zip들을 내려받아 md5를 확인하고 클라이언트 폴더에 푼다.
// 실행 중인 exe·DLL은 덮을 수 없으므로 <이름>.old로 바꾸고 새 파일을 쓴다. .old는 다음 실행 때 지운다.
#include <atomic>
#include <cstdint>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

namespace wxframe {

struct UpdateFile {
  std::string name, url, md5;
};

struct UpdateInfo {
  std::string version;
  std::vector<UpdateFile> files;
};

class Updater {
 public:
  enum State { Idle, Checking, UpToDate, Available, Downloading, Ready, Failed };

  ~Updater();
  void check(const std::string& url, const std::string& current_version);  // 작업 스레드
  void apply(const std::string& client_dir);                              // 작업 스레드: 내려받고 푼다
  State state() const { return state_; }
  std::string message() const;
  const UpdateInfo& info() const { return info_; }
  int percent() const { return percent_; }

  // 아래는 화면 없이 쓰는 부품(검사도 쓴다)
  static int compare_versions(const std::string& a, const std::string& b);  // a<b면 음수
  static bool parse_info(const std::string& json, UpdateInfo& out, std::string& err);
  static std::string md5_hex(const std::vector<uint8_t>& data);
  // zip을 dir에 푼다. 이미 있는 파일은 지우고, 지울 수 없으면(실행 중) .old로 바꾼 뒤 쓴다. 폴더 밖을 가리키는 항목은 거부
  static bool extract_zip(const std::string& zip_path, const std::string& dir, std::string& err);
  static void remove_old_files(const std::string& dir);  // 지난 업데이트가 남긴 .old
  static bool download(const std::string& url, std::vector<uint8_t>& out, std::string& err,
                       std::atomic<int>* percent = nullptr);
  static bool restart_self();  // 지금 exe를 다시 띄운다(부른 쪽은 곧 끝낸다)

 private:
  void set(State s, const std::string& msg);
  void join();

  std::thread worker_;
  std::atomic<State> state_{Idle};
  std::atomic<int> percent_{0};
  mutable std::mutex mu_;
  std::string message_;
  UpdateInfo info_;
};

}  // namespace wxframe
