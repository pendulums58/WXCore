#pragma once
// 프레임 쪽 대전 래퍼. 공개 C API만 쓴다(서버·관전도 같은 길).
// 사건은 메시지로 받아 로그에 쌓고, 화면은 매 프레임 조회 API로 그린다.
#include <cstdint>
#include <map>
#include <optional>
#include <string>
#include <vector>

#include "card_db.h"
#include "wx_api.h"

namespace wxframe {

struct ReqOption {
  uint32_t value = 0;  // 응답으로 보낼 값(SELECT_CARDS면 handle, SELECT_ACTION이면 번호)
  uint8_t kind = 0;    // SELECT_ACTION: WX_ACT_*
  uint32_t handle = 0;
  uint16_t zone = 0xFFFF;
  uint32_t effect = 0;
};

struct Request {
  uint8_t type = 0, player = 0;
  uint32_t hint = 0, min = 0, max = 0;
  std::vector<ReqOption> options;
  bool cancelable = false;
};

struct ZoneMeta {
  uint16_t id = 0;
  uint8_t owner = 0;
  std::string name;
};

class Game {
 public:
  explicit Game(wxtest::CardDb& db) : db_(db) {}
  ~Game();
  Game(const Game&) = delete;
  Game& operator=(const Game&) = delete;

  bool start(const wxtest::DeckFile& p1, const wxtest::DeckFile& p2, uint64_t seed, bool practice, std::string& err);
  bool running() const { return duel_ != nullptr; }
  void reset();

  // 응답이 필요하거나 대전이 끝날 때까지 진행하고 메시지를 꺼낸다
  void advance();
  bool respond(const std::vector<uint32_t>& picks);
  bool cancel();
  bool undo();

  wx_duel* duel() const { return duel_; }
  const std::optional<Request>& request() const { return req_; }
  const std::vector<std::string>& log(int view) const { return log_[view]; }
  const std::string& retry(int view) const { return retry_[view]; }
  bool ended() const { return ended_; }
  int winner() const { return winner_; }
  bool practice() const { return practice_; }

  const std::vector<ZoneMeta>& zones() const { return zones_; }
  int zone(uint8_t owner, const std::string& name) const;  // 없으면 -1
  std::string card_label(int view, uint32_t handle);       // 이름(모르면 뒷면)
  wx_card_info card(int view, uint32_t handle);
  std::vector<uint32_t> zone_cards(int view, int zone);

  wxtest::CardDb& db() { return db_; }

 private:
  void pull();
  void parse_request(const uint8_t* m, size_t len);
  std::string describe(int view, const uint8_t* m, size_t len);

  wxtest::CardDb& db_;
  wx_duel* duel_ = nullptr;
  std::optional<Request> req_;
  std::vector<std::string> log_[4];
  std::string retry_[4];
  std::vector<ZoneMeta> zones_;
  bool ended_ = false, practice_ = false;
  int winner_ = -1;
};

// 표시용 이름
const char* hint_name(uint32_t hint);
const char* phase_name(uint32_t phase);
std::string zone_label(const std::string& name);

}  // namespace wxframe
