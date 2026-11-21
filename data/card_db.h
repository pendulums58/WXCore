#pragma once
// 카드 DB(expansions/official/wixoss.db)와 덱 파일(decks/*.json)을 읽는다. 러너 쪽 코드다.
// 코어는 파일을 직접 열지 않으므로 여기서 읽은 것을 콜백으로 넘긴다.
#include <map>
#include <memory>
#include <string>
#include <vector>

#include "carddata.h"
#include "wx_api.h"

struct sqlite3;

namespace wxtest {

class CardDb {
 public:
  CardDb() = default;
  ~CardDb();
  CardDb(const CardDb&) = delete;
  CardDb& operator=(const CardDb&) = delete;

  // 읽기 전용으로 연다. 실패하면 false, error()에 이유
  bool open(const std::string& path);
  bool is_open() const { return db_ != nullptr; }
  const std::string& error() const { return error_; }

  bool read(wx::Cid cid, wx::CardData& out);
  // 카드 번호(인쇄본) → cid. 없으면 0
  wx::Cid cid_of(const std::string& card_no);
  std::string name_of(wx::Cid cid);  // 일본어 이름
  // 표시용 텍스트. 한국어가 있으면 한국어, 없으면 일본어
  struct Text {
    std::string name, ability, life_burst;
  };
  Text text_of(wx::Cid cid);
  // C API 콜백용. 문자열 포인터는 다음 호출 전까지 유효하다
  bool fill(wx::Cid cid, wx_card_data* out);

 private:
  sqlite3* db_ = nullptr;
  std::string error_;
  std::map<wx::Cid, wx::CardData> cache_;
  std::map<wx::Cid, Text> text_cache_;
  std::string fill_buf_[3];
};

struct DeckFile {
  std::string name, format;
  std::vector<wx::Cid> main, lrig;
  wx::Cid start_center = 0;
  std::vector<wx::Cid> start_assists;
};

// decks/*.json을 읽어 cid로 바꾼다. 모르는 카드 번호가 있으면 false, error에 이유
bool load_deck(const std::string& path, CardDb& db, DeckFile& out, std::string& error);

// 데이터 폴더(레포 루트). 빌드할 때 정한다
std::string data_dir();
// 스크립트 파일 읽기(expansions/official/script/c<cid>.lua). 없으면 false
bool read_script_file(const std::string& name, std::string& code);

}  // namespace wxtest
