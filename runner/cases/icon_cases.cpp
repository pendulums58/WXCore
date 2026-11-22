// 카드 텍스트 아이콘 매핑(frame/icon_text.cpp). 화면 없이 토큰 나누기만
#include <filesystem>
#include <fstream>

#include "icon_text.h"
#include "test.h"

TEST_CASE("icons: 매핑된 토큰만 그림으로, 같은 자리에서는 가장 긴 토큰, 나머지는 원문", "결정 2026-11-22: 키워드 아이콘") {
  wxframe::IconMap m;
  CHECK(m.add(R"({"_note": "설명", "【出】": "arrival.png", "【チーム】": "team.png", "【チーム出】": "arrival_team.png",
                  "《コインアイコン》": "coin.png"})",
              "D:/icons", false));
  CHECK(m.size() == 4);  // "_note"는 건너뛴다
  const auto s = m.split("【チーム出】《コインアイコン》：《燃盛　遊月・鍵》を得る。");
  CHECK(s.size() == 3);
  CHECK(s[0].image.find("arrival_team.png") != std::string::npos && s[0].text.empty());
  CHECK(s[1].image.find("coin.png") != std::string::npos);
  CHECK(s[2].image.empty() && s[2].text == "：《燃盛　遊月・鍵》を得る。");  // 카드 이름 인용은 그대로
  CHECK(m.split("글자만").size() == 1);
}

TEST_CASE("icons: 데이터 폴더 순서대로 읽고 뒤가 덮는다, 그림 파일이 없는 토큰은 원문 그대로", "결정 2026-11-22: 키워드 아이콘") {
  namespace fs = std::filesystem;
  const fs::path base = fs::temp_directory_path() / "wx_icons_case";
  std::error_code ec;
  fs::remove_all(base, ec);
  for (const char* d : {"a/icons", "b/icons"}) fs::create_directories(base / d, ec);
  std::ofstream(base / "a/icons/icons.json") << R"({"【出】": "a.png", "【自】": "missing.png"})";
  std::ofstream(base / "a/icons/a.png") << "x";
  std::ofstream(base / "b/icons/icons.json") << R"({"【出】": "b.png"})";
  std::ofstream(base / "b/icons/b.png") << "x";
  wxframe::IconMap m;
  CHECK(m.load({(base / "a").string(), (base / "b").string(), (base / "none").string()}) == 2);
  CHECK(m.size() == 1);  // 【自】는 그림이 없어 매핑하지 않는다
  const auto s = m.split("【出】【自】");
  CHECK(s.size() == 2 && s[0].image.find("b.png") != std::string::npos && s[1].text == "【自】");
  fs::remove_all(base, ec);
}
