// 클라이언트 업데이터의 부품: md5, 버전 비교, update.json, zip 풀기(파일 바꾸기·폴더 밖 경로 거부). 네트워크 없이
#include <miniz.h>

#include <filesystem>
#include <fstream>
#include <sstream>

#include "test.h"
#include "updater.h"

namespace {

namespace fs = std::filesystem;

std::string read_all(const fs::path& p) {
  std::ifstream f(p, std::ios::binary);
  std::stringstream ss;
  ss << f.rdbuf();
  return ss.str();
}

std::vector<uint8_t> bytes(const std::string& s) { return std::vector<uint8_t>(s.begin(), s.end()); }

}  // namespace

TEST_CASE("updater: md5(RFC 1321 예시)와 버전 비교", "EDOPro ClientUpdater(md5 확인)") {
  using wxframe::Updater;
  CHECK(Updater::md5_hex({}) == "d41d8cd98f00b204e9800998ecf8427e");
  CHECK(Updater::md5_hex(bytes("abc")) == "900150983cd24fb0d6963f7d28e17f72");
  CHECK(Updater::md5_hex(bytes("The quick brown fox jumps over the lazy dog")) == "9e107d9d372bb6826bd81d3542a419d6");
  CHECK(Updater::md5_hex(bytes(std::string(1000, 'a'))) == "cabe45dcc9ae5b66ba86600cca6b8ba8");
  CHECK(Updater::compare_versions("0.1.0", "0.2.0") < 0);
  CHECK(Updater::compare_versions("0.10.0", "0.9.9") > 0);
  CHECK(Updater::compare_versions("1.0", "1.0.0") == 0);
}

TEST_CASE("updater: update.json을 읽는다", "결정 2026-11-22: 클라이언트는 릴리즈 목록") {
  wxframe::UpdateInfo info;
  std::string err;
  CHECK(wxframe::Updater::parse_info(R"({"version":"0.2.0","files":[{"name":"WXCore-0.2.0.zip","url":"https://example.com/a.zip","md5":"abc"}]})",
                                     info, err));
  CHECK(info.version == "0.2.0" && info.files.size() == 1 && info.files[0].md5 == "abc");
  CHECK(!wxframe::Updater::parse_info(R"({"files":[]})", info, err));
}

TEST_CASE("updater: 폴더가 든 이름·빈 md5·https가 아닌 주소는 거부한다", "점검 2026-11-24 #4-3") {
  const std::string md5 = "d41d8cd98f00b204e9800998ecf8427e";
  using wxframe::Updater;
  CHECK(Updater::valid_file({"WXCore-0.2.0.zip", "https://example.com/a.zip", md5}));
  CHECK(!Updater::valid_file({"../a.zip", "https://example.com/a.zip", md5}));
  CHECK(!Updater::valid_file({"..\\a.zip", "https://example.com/a.zip", md5}));
  CHECK(!Updater::valid_file({"C:a.zip", "https://example.com/a.zip", md5}));
  CHECK(!Updater::valid_file({"a.zip", "http://example.com/a.zip", md5}));
  CHECK(!Updater::valid_file({"a.zip", "https://example.com/a.zip", ""}));
  std::vector<uint8_t> data;
  std::string err;
  CHECK(!Updater::download("file:///C:/Windows/win.ini", data, err) && data.empty());
}

TEST_CASE("updater: zip을 풀어 파일을 바꾸고, 폴더 밖을 가리키는 항목은 거부한다", "EDOPro ClientUpdater(zip 풀기)") {
  const fs::path root = fs::temp_directory_path() / "wx_update_case";
  std::error_code ec;
  fs::remove_all(root, ec);
  fs::create_directories(root / "client" / "config", ec);
  std::ofstream(root / "client" / "config" / "configs.json", std::ios::binary) << "old";
  const std::string zip = (root / "up.zip").string();
  const std::string a = "new config", b = "new dll";
  CHECK(mz_zip_add_mem_to_archive_file_in_place(zip.c_str(), "config/configs.json", a.data(), a.size(), nullptr, 0, MZ_DEFAULT_LEVEL));
  CHECK(mz_zip_add_mem_to_archive_file_in_place(zip.c_str(), "wxcore.dll", b.data(), b.size(), nullptr, 0, MZ_DEFAULT_LEVEL));
  std::string err;
  CHECK(wxframe::Updater::extract_zip(zip, (root / "client").string(), err));
  CHECK(read_all(root / "client" / "config" / "configs.json") == a);
  CHECK(read_all(root / "client" / "wxcore.dll") == b);

  // 열려 있어 지울 수 없는 파일은 .old로 바꾸고 새로 쓴다(실행 중인 exe·DLL)
  {
    std::ifstream busy(root / "client" / "wxcore.dll", std::ios::binary);  // Windows에서는 열린 파일을 못 지운다
    const std::string c = "newer dll";
    const std::string zip2 = (root / "up2.zip").string();
    CHECK(mz_zip_add_mem_to_archive_file_in_place(zip2.c_str(), "wxcore.dll", c.data(), c.size(), nullptr, 0, MZ_DEFAULT_LEVEL));
    CHECK(wxframe::Updater::extract_zip(zip2, (root / "client").string(), err));
    busy.close();
    CHECK(read_all(root / "client" / "wxcore.dll") == c);
  }
  wxframe::Updater::remove_old_files((root / "client").string());
  CHECK(!fs::exists(root / "client" / "wxcore.dll.old"));

  // 폴더 밖 경로(zip slip)
  const std::string evil = (root / "evil.zip").string();
  const std::string e = "x";
  if (mz_zip_add_mem_to_archive_file_in_place(evil.c_str(), "../escaped.txt", e.data(), e.size(), nullptr, 0, MZ_DEFAULT_LEVEL)) {
    CHECK(!wxframe::Updater::extract_zip(evil, (root / "client").string(), err));
    CHECK(!fs::exists(root / "escaped.txt"));
  }
  // 드라이브 루트(\\x)를 가리키는 항목
  const std::string evil2 = (root / "evil2.zip").string();
  if (mz_zip_add_mem_to_archive_file_in_place(evil2.c_str(), "\\wx_escaped.txt", e.data(), e.size(), nullptr, 0, MZ_DEFAULT_LEVEL))
    CHECK(!wxframe::Updater::extract_zip(evil2, (root / "client").string(), err));
  fs::remove_all(root, ec);
}
