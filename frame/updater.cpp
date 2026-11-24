#include "updater.h"

#include <curl/curl.h>
#include <miniz.h>

#include <cstring>
#include <filesystem>
#include <fstream>
#include <sstream>

#include "json.h"

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#else
#include <unistd.h>
#endif

namespace wxframe {

namespace {

namespace fs = std::filesystem;

// ── MD5(RFC 1321) ──
struct Md5 {
  uint32_t a = 0x67452301, b = 0xefcdab89, c = 0x98badcfe, d = 0x10325476;
  void block(const uint8_t* p) {
    static const uint32_t K[64] = {
        0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee, 0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
        0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be, 0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
        0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa, 0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
        0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed, 0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
        0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c, 0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
        0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05, 0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
        0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039, 0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
        0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1, 0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391};
    static const int R[64] = {7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 5, 9,  14, 20, 5, 9,
                               14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
                               4, 11, 16, 23, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21};
    uint32_t w[16];
    for (int i = 0; i < 16; ++i) w[i] = p[i * 4] | (p[i * 4 + 1] << 8) | (p[i * 4 + 2] << 16) | (static_cast<uint32_t>(p[i * 4 + 3]) << 24);
    uint32_t A = a, B = b, C = c, D = d;
    for (int i = 0; i < 64; ++i) {
      uint32_t f;
      int g;
      if (i < 16) f = (B & C) | (~B & D), g = i;
      else if (i < 32) f = (D & B) | (~D & C), g = (5 * i + 1) % 16;
      else if (i < 48) f = B ^ C ^ D, g = (3 * i + 5) % 16;
      else f = C ^ (B | ~D), g = (7 * i) % 16;
      const uint32_t t = D;
      D = C;
      C = B;
      const uint32_t x = A + f + K[i] + w[g];
      B = B + ((x << R[i]) | (x >> (32 - R[i])));
      A = t;
    }
    a += A, b += B, c += C, d += D;
  }
};

constexpr size_t kMaxDownload = 512u * 1024 * 1024;       // 받는 파일 하나
constexpr uint64_t kMaxUnzipped = 2ull * 1024 * 1024 * 1024;  // zip을 푼 크기의 합

struct Transfer {
  std::atomic<int>* percent;
  const std::atomic<bool>* stop;
};

size_t on_write(char* p, size_t size, size_t n, void* user) {
  auto* out = static_cast<std::vector<uint8_t>*>(user);
  if (out->size() + size * n > kMaxDownload) return 0;  // 너무 크면 받기를 끊는다
  out->insert(out->end(), p, p + size * n);
  return size * n;
}

int on_progress(void* user, curl_off_t total, curl_off_t now, curl_off_t, curl_off_t) {
  auto* t = static_cast<Transfer*>(user);
  if (t->percent && total > 0) t->percent->store(static_cast<int>(now * 100 / total));
  return t->stop && t->stop->load() ? 1 : 0;  // 0이 아니면 멈춘다
}

fs::path u8(const std::string& s) { return fs::path(std::u8string(reinterpret_cast<const char8_t*>(s.data()), s.size())); }

}  // namespace

int Updater::compare_versions(const std::string& a, const std::string& b) {
  // 「1.2.10」처럼 점으로 나눈 수를 차례로 비교한다
  std::stringstream sa(a), sb(b);
  for (int i = 0; i < 4; ++i) {
    std::string pa, pb;
    std::getline(sa, pa, '.');
    std::getline(sb, pb, '.');
    const long va = pa.empty() ? 0 : std::strtol(pa.c_str(), nullptr, 10);
    const long vb = pb.empty() ? 0 : std::strtol(pb.c_str(), nullptr, 10);
    if (va != vb) return va < vb ? -1 : 1;
  }
  return 0;
}

bool Updater::parse_info(const std::string& json, UpdateInfo& out, std::string& err) {
  wxtest::Json j;
  if (!wxtest::parse_json(json, j) || !j.obj()) {
    err = "update.json 형식 오류";
    return false;
  }
  out = UpdateInfo{};
  if (auto* v = j.get("version"); v && v->str()) out.version = *v->str();
  if (auto* files = j.get("files"); files && files->arr())
    for (const auto& f : *files->arr()) {
      UpdateFile u;
      if (auto* x = f.get("name"); x && x->str()) u.name = *x->str();
      if (auto* x = f.get("url"); x && x->str()) u.url = *x->str();
      if (auto* x = f.get("md5"); x && x->str()) u.md5 = *x->str();
      if (!u.name.empty() && !u.url.empty()) out.files.push_back(std::move(u));
    }
  if (out.version.empty()) {
    err = "update.json에 version이 없음";
    return false;
  }
  return true;
}

bool Updater::valid_file(const UpdateFile& f) {
  if (f.url.rfind("https://", 0) != 0 || f.md5.size() != 32) return false;
  if (f.md5.find_first_not_of("0123456789abcdef") != std::string::npos) return false;
  if (f.name.empty() || f.name == "." || f.name == "..") return false;
  return f.name.find_first_of("/\\:") == std::string::npos;
}

std::string Updater::md5_hex(const std::vector<uint8_t>& data) {
  Md5 m;
  std::vector<uint8_t> buf(data);
  const uint64_t bits = static_cast<uint64_t>(data.size()) * 8;
  buf.push_back(0x80);
  while (buf.size() % 64 != 56) buf.push_back(0);
  for (int i = 0; i < 8; ++i) buf.push_back(static_cast<uint8_t>(bits >> (8 * i)));
  for (size_t i = 0; i < buf.size(); i += 64) m.block(buf.data() + i);
  char out[33];
  const uint32_t parts[4] = {m.a, m.b, m.c, m.d};
  for (int i = 0; i < 4; ++i)
    for (int k = 0; k < 4; ++k) std::snprintf(out + i * 8 + k * 2, 3, "%02x", (parts[i] >> (8 * k)) & 0xff);
  return std::string(out, 32);
}

bool Updater::extract_zip(const std::string& zip_path, const std::string& dir, std::string& err) {
  std::ifstream f(fs::path(zip_path), std::ios::binary);
  if (!f) {
    err = zip_path + ": 열 수 없음";
    return false;
  }
  std::vector<char> data((std::istreambuf_iterator<char>(f)), std::istreambuf_iterator<char>());
  mz_zip_archive zip{};
  if (!mz_zip_reader_init_mem(&zip, data.data(), data.size(), 0)) {
    err = zip_path + ": zip 형식 오류";
    return false;
  }
  bool ok = true;
  uint64_t total = 0;
  const fs::path root(dir);  // 폴더 경로는 다른 코드와 같은 방식, zip 안 이름만 UTF-8
  for (mz_uint i = 0; i < mz_zip_reader_get_num_files(&zip) && ok; ++i) {
    mz_zip_archive_file_stat st;
    if (!mz_zip_reader_file_stat(&zip, i, &st)) continue;
    const std::string name = st.m_filename;
    total += st.m_uncomp_size;
    if (total > kMaxUnzipped) {
      err = zip_path + ": 푼 크기가 너무 크다";
      ok = false;
      break;
    }
    // 폴더 밖을 가리키는 항목(zip slip)은 거부
    const fs::path rel = u8(name).lexically_normal();
    if (rel.has_root_path() || (!rel.empty() && *rel.begin() == "..")) {
      err = "zip에 폴더 밖 경로가 있다: " + name;
      ok = false;
      break;
    }
    const fs::path target = root / rel;
    std::error_code ec;
    if (mz_zip_reader_is_file_a_directory(&zip, i)) {
      fs::create_directories(target, ec);
      continue;
    }
    size_t size = 0;
    void* p = mz_zip_reader_extract_to_heap(&zip, i, &size, 0);
    if (!p) {
      err = name + ": 풀기 실패";
      ok = false;
      break;
    }
    fs::create_directories(target.parent_path(), ec);
    if (fs::exists(target, ec) && !fs::remove(target, ec)) {
      // 실행 중이라 지울 수 없으면 이름을 바꿔 두고 새로 쓴다(다음 실행 때 .old를 지운다)
      fs::path old = target;
      old += ".old";
      fs::remove(old, ec);
      fs::rename(target, old, ec);
    }
    std::ofstream out(target, std::ios::binary);
    out.write(static_cast<const char*>(p), static_cast<std::streamsize>(size));
    mz_free(p);
    if (!out) {
      err = name + ": 쓰기 실패";
      ok = false;
    }
  }
  mz_zip_reader_end(&zip);
  return ok;
}

void Updater::remove_old_files(const std::string& dir) {
  std::error_code ec;
  const fs::path root(dir);
  for (auto it = fs::recursive_directory_iterator(root, fs::directory_options::skip_permission_denied, ec);
       it != fs::recursive_directory_iterator(); it.increment(ec)) {
    if (ec) break;
    const std::string top = it->path().lexically_relative(root).begin()->string();
    // 카드 이미지·저장소·개인 작업물·덱은 업데이트가 건드리지 않는다
    if (it->is_directory(ec) && (top == "pics" || top == "repositories" || top == "expansions" || top == "decks" || top == "build")) {
      it.disable_recursion_pending();
      continue;
    }
    if (it->path().extension() == ".old") fs::remove(it->path(), ec);
  }
}

bool Updater::download(const std::string& url, std::vector<uint8_t>& out, std::string& err, std::atomic<int>* percent,
                       const std::atomic<bool>* stop) {
  static bool inited = (curl_global_init(CURL_GLOBAL_DEFAULT), true);
  (void)inited;
  CURL* c = curl_easy_init();
  if (!c) {
    err = "curl 초기화 실패";
    return false;
  }
  out.clear();
  curl_easy_setopt(c, CURLOPT_URL, url.c_str());
  curl_easy_setopt(c, CURLOPT_FOLLOWLOCATION, 1L);  // GitHub 릴리즈는 다른 주소로 넘긴다
  curl_easy_setopt(c, CURLOPT_USERAGENT, "WXCore-updater");
  curl_easy_setopt(c, CURLOPT_FAILONERROR, 1L);
  curl_easy_setopt(c, CURLOPT_PROTOCOLS_STR, "https");
  curl_easy_setopt(c, CURLOPT_REDIR_PROTOCOLS_STR, "https");
  curl_easy_setopt(c, CURLOPT_MAXREDIRS, 10L);
  curl_easy_setopt(c, CURLOPT_CONNECTTIMEOUT, 15L);
  curl_easy_setopt(c, CURLOPT_LOW_SPEED_LIMIT, 1024L);  // 30초 동안 초당 1KB도 안 오면 실패
  curl_easy_setopt(c, CURLOPT_LOW_SPEED_TIME, 30L);
  curl_easy_setopt(c, CURLOPT_WRITEFUNCTION, on_write);
  curl_easy_setopt(c, CURLOPT_WRITEDATA, &out);
  Transfer t{percent, stop};
  curl_easy_setopt(c, CURLOPT_NOPROGRESS, 0L);
  curl_easy_setopt(c, CURLOPT_XFERINFOFUNCTION, on_progress);
  curl_easy_setopt(c, CURLOPT_XFERINFODATA, &t);
  const CURLcode r = curl_easy_perform(c);
  if (r != CURLE_OK) err = std::string("받기 실패: ") + curl_easy_strerror(r) + " (" + url + ")";
  curl_easy_cleanup(c);
  return r == CURLE_OK;
}

bool Updater::restart_self() {
#ifdef _WIN32
  wchar_t exe[MAX_PATH];
  GetModuleFileNameW(nullptr, exe, MAX_PATH);
  STARTUPINFOW si{};
  si.cb = sizeof si;
  PROCESS_INFORMATION pi{};
  const std::wstring dir = fs::path(exe).parent_path().wstring();
  if (!CreateProcessW(exe, nullptr, nullptr, nullptr, FALSE, 0, nullptr, dir.c_str(), &si, &pi)) return false;
  CloseHandle(pi.hThread);
  CloseHandle(pi.hProcess);
  return true;
#else
  return false;
#endif
}

Updater::~Updater() {
  stop_ = true;
  join();
}

void Updater::join() {
  if (worker_.joinable()) worker_.join();
}

void Updater::set(State s, const std::string& msg) {
  std::lock_guard<std::mutex> lock(mu_);
  message_ = msg;
  state_ = s;
}

std::string Updater::message() const {
  std::lock_guard<std::mutex> lock(mu_);
  return message_;
}

void Updater::check(const std::string& url, const std::string& current) {
  if (url.empty() || state_ == Checking || state_ == Downloading) return;
  join();
  set(Checking, "새 버전 확인 중");
  worker_ = std::thread([this, url, current] {
    std::vector<uint8_t> data;
    std::string err;
    UpdateInfo info;
    if (!download(url, data, err, nullptr, &stop_) || !parse_info(std::string(data.begin(), data.end()), info, err)) {
      set(Failed, err);
      return;
    }
    {
      std::lock_guard<std::mutex> lock(mu_);
      info_ = info;
    }
    if (compare_versions(current, info.version) < 0) set(Available, "새 버전 " + info.version);
    else set(UpToDate, "최신 버전");
  });
}

void Updater::apply(const std::string& client_dir) {
  if (state_ != Available) return;
  join();
  set(Downloading, "내려받는 중");
  worker_ = std::thread([this, client_dir] {
    const fs::path dir = fs::path(client_dir) / "updates";
    std::error_code ec;
    fs::create_directories(dir, ec);
    for (const auto& f : info_.files) {
      std::vector<uint8_t> data;
      std::string err;
      percent_ = 0;
      set(Downloading, f.name + " 내려받는 중");
      if (!valid_file(f)) {
        set(Failed, f.name + ": update.json의 파일 이름·주소·md5가 올바르지 않다");
        return;
      }
      if (!download(f.url, data, err, &percent_, &stop_)) {
        set(Failed, err);
        return;
      }
      if (md5_hex(data) != f.md5) {
        set(Failed, f.name + ": md5가 다르다(받다가 깨졌을 수 있다)");
        return;
      }
      const fs::path zip = dir / u8(f.name);
      std::ofstream(zip, std::ios::binary).write(reinterpret_cast<const char*>(data.data()), static_cast<std::streamsize>(data.size()));
      set(Downloading, f.name + " 푸는 중");
      if (!extract_zip(zip.string(), client_dir, err)) {
        set(Failed, err);
        return;
      }
      fs::remove(zip, ec);
    }
    set(Ready, info_.version + " 설치함. 다시 시작하면 적용");
  });
}

}  // namespace wxframe
