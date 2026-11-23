#pragma once
// 카드 DB(최상단 wixoss.db 등)와 덱 파일(decks/*.json)을 읽는다. 러너 쪽 코드다.
// 코어는 파일을 직접 열지 않으므로 여기서 읽은 것을 콜백으로 넘긴다.
#include <map>
#include <memory>
#include <string>
#include <vector>

#include "carddata.h"
#include "wx_api.h"

struct sqlite3;

namespace wxtest {

// prints.formats 비트(포맷 아이콘)
constexpr uint32_t kFormatKey = 1;
constexpr uint32_t kFormatDiva = 2;

// 덱 에디터 검색용 카드 한 줄. 토큰·코인·크래프트처럼 덱에 넣을 수 없는 카드는 목록에 없다
struct CardEntry {
  wx::Cid cid = 0;
  wx::Cid alias = 0;
  uint32_t type = 0;  // wx::CardType 비트
  uint8_t color = 0;
  int level = 0, limit = 0, power = 0;
  bool life_burst = false;
  uint32_t formats = 0;  // 인쇄본들의 포맷 아이콘 합
  std::string name;      // 표시 이름(한국어가 있으면 한국어)
  std::string name_ja;   // 일본어 이름(오리카는 비어 있을 수 있다)
  std::string card_no;   // 기본 인쇄본 번호
  std::vector<std::string> classes;
  std::string search;  // 이름·읽기·카드 번호·클래스·텍스트를 이은 것(ASCII는 소문자)
  // 「같은 이름」 판정 키: alias가 있으면 alias, 없으면 자기 cid(이름 문자열은 오리카에 없을 수 있다)
  wx::Cid name_key() const { return alias ? alias : cid; }
};

class CardDb {
 public:
  CardDb() = default;
  ~CardDb();
  CardDb(const CardDb&) = delete;
  CardDb& operator=(const CardDb&) = delete;

  // DB 하나를 읽기 전용으로 더한다. 나중에 연 DB가 같은 cid를 덮는다. 실패하면 false, error()에 이유
  bool open(const std::string& path);
  // 데이터 폴더(data_dirs 순서)의 *.db를 모두 연다. 연 개수
  int open_all();
  void close_all();  // 다시 열기 전에(저장소가 갱신됐을 때)
  bool is_open() const { return !dbs_.empty(); }
  const std::vector<std::string>& paths() const { return paths_; }
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
  // 효과 설명 번호(desc = cid × 32 + slot) → 문장. 한국어가 있으면 한국어. 없으면 빈 문자열(설계: 효과 설명 문자열)
  std::string desc_text(uint32_t desc);
  // C API 콜백용. 문자열 포인터는 다음 호출 전까지 유효하다
  bool fill(wx::Cid cid, wx_card_data* out);
  // 덱에 넣을 수 있는 카드 전부(cid 순). 처음 부를 때 읽어 둔다
  const std::vector<CardEntry>& all_cards();
  const CardEntry* entry(wx::Cid cid);
  // 같은 이름(name_key)의 카드 중 bits 포맷 아이콘이 붙은 인쇄본이 있는가(포맷 FAQ: 「同名のカードであれば、以前のカードも使用できます」)
  bool name_has_format(wx::Cid name_key, uint32_t bits);
  // 기본 인쇄본(idx가 가장 작은 것)의 카드 번호. 없으면 빈 문자열
  std::string card_no_of(wx::Cid cid);

 private:
  std::vector<sqlite3*> dbs_;  // 우선순위 낮은 것부터
  std::vector<std::string> paths_;
  std::string error_;
  std::map<wx::Cid, wx::CardData> cache_;
  std::map<wx::Cid, Text> text_cache_;
  std::map<uint32_t, std::string> desc_cache_;
  std::string fill_buf_[3];
  std::vector<CardEntry> all_;
  std::map<wx::Cid, size_t> all_index_;
  std::map<wx::Cid, uint32_t> name_formats_;  // name_key → 같은 이름 카드들의 포맷 아이콘 합
};

struct DeckFile {
  std::string name, format;
  std::vector<wx::Cid> main, lrig;
  wx::Cid start_center = 0;
  std::vector<wx::Cid> start_assists;
  std::map<wx::Cid, std::string> card_no;  // 파일에 적힌 카드 번호(저장할 때 그대로 쓴다)
};

// decks/*.json을 읽어 cid로 바꾼다. 모르는 카드 번호가 있으면 false, error에 이유
bool load_deck(const std::string& path, CardDb& db, DeckFile& out, std::string& error);
// 덱 파일 내용(JSON 문자열)으로. 온라인에서 게스트가 보낸 덱. label은 오류 메시지 앞에 붙는다
bool load_deck_text(const std::string& text, CardDb& db, DeckFile& out, std::string& error, const std::string& label = "덱");
// 덱 파일 내용 그대로(보내기용)
bool read_deck_text(const std::string& path, std::string& text);

// 덱 파일로 저장한다. 카드 번호는 deck.card_no에 있으면 그것, 없으면 기본 인쇄본 번호
bool save_deck(const std::string& path, CardDb& db, const DeckFile& deck, std::string& error);

// 데이터 폴더(레포 루트). 빌드할 때 정한다
std::string data_dir();
// 카드 데이터 폴더: 최상단(공식, YGOPro의 cards.cdb 자리) → repositories/*/(저장소, 자동 업데이트)
// → expansions/(개인 작업물, 하위 폴더는 안 읽는다). 뒤가 우선한다.
// 폴더마다 *.db, script/, formats/, pics/를 둘 수 있다
std::vector<std::string> data_dirs();
// data_dirs의 <sub>/<name> 중 우선순위가 가장 높은 것. 없으면 빈 문자열
std::string find_data_file(const std::string& sub, const std::string& name);
// 스크립트 파일 읽기(<데이터 폴더>/script/c<cid>.lua). 없으면 false
bool read_script_file(const std::string& name, std::string& code);

}  // namespace wxtest
