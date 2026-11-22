#pragma once
// 프레임 쪽 대전 래퍼. 공개 C API만 쓴다(서버·관전도 같은 길).
// 사건은 메시지로 받아 로그에 쌓고, 화면은 매 프레임 조회 API로 그린다.
#include <cstdint>
#include <functional>
#include <map>
#include <optional>
#include <string>
#include <vector>

#include "card_db.h"
#include "field_model.h"
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
  uint32_t source = 0;  // 무엇에 대한 요청인가(카드 handle, 0 = 없음)
};

// 로그 한 줄. 그 뷰가 받은 메시지로 만들므로 모르는 카드는 cid 0
struct LogLine {
  enum Kind : uint8_t { Normal, Turn, Phase, System, Error };
  Kind kind = Normal;
  int who = -1;        // 그 일이 일어난 쪽 플레이어(없으면 -1)
  std::string text;    // 「드로」「시그니 배치(시그니 좌)」 같은 일
  uint32_t cid = 0;    // 관련 카드(마우스를 올리면 미리보기)
  int count = 1;       // 같은 일이 이어지면 묶는다(×N)
};

class Game {
 public:
  explicit Game(wxtest::CardDb& db) : db_(db) {}
  ~Game();
  Game(const Game&) = delete;
  Game& operator=(const Game&) = delete;

  bool start(const wxtest::DeckFile& p1, const wxtest::DeckFile& p2, uint64_t seed, bool practice, std::string& err);
  bool running() const { return duel_ != nullptr || remote_; }
  void reset();

  // 온라인 게스트: 코어 없이 방장이 보낸 메시지(seat 뷰)로 장을 만든다. 응답은 send로 방장에게 보낸다
  using SendFn = std::function<void(const std::vector<uint32_t>& picks, bool cancel)>;
  void start_remote(int seat, SendFn send);
  void feed(const uint8_t* data, size_t n);  // 메시지 여러 개(코어 메시지와 UPDATE)
  bool remote() const { return remote_; }
  // 방장: 뷰마다 나가는 메시지(코어 메시지와 UPDATE)를 받는다. 게스트에게 그대로 보낸다
  std::function<void(int view, const uint8_t* m, size_t len)> on_message;

  // 응답이 필요하거나 대전이 끝날 때까지 진행하고 메시지를 꺼낸다
  void advance();
  bool respond(const std::vector<uint32_t>& picks);
  bool cancel();
  bool undo();

  wx_duel* duel() const { return duel_; }
  // 게스트가 응답을 보내고 방장의 답을 기다리는 동안은 요청이 없는 것으로 보인다
  const std::optional<Request>& request() const { return awaiting_ ? no_request_ : req_; }
  // 원격(게스트·관전)은 자기 뷰 하나만 있으므로 어느 뷰를 물어도 그 뷰로 답한다
  const std::vector<LogLine>& log(int view) const { return log_[remote_ ? seat_ : view]; }
  const std::string& retry(int view) const { return retry_[remote_ ? seat_ : view]; }
  int seat() const { return seat_; }  // 원격일 때 내 뷰(1 게스트, 2 관전)
  bool ended() const { return ended_; }
  int winner() const { return winner_; }
  bool practice() const { return practice_; }

  const std::vector<ZoneMeta>& zones() const { return zones_; }
  int zone(uint8_t owner, const std::string& name) const;  // 없으면 -1
  std::string card_label(int view, uint32_t handle);       // 이름(모르면 뒷면)
  // 화면은 뷰마다 장 모델(메시지 + UPDATE로 재구성)을 읽는다. 게스트도 같은 길(설계 결정 2026-11-22)
  wx_card_info card(int view, uint32_t handle);
  std::vector<uint32_t> zone_cards(int view, int zone);
  const FieldModel& model(int view) const { return model_[remote_ ? seat_ : (view < 3 ? view : 0)]; }
  // 검사용: 메시지만으로 재구성한 존 내용이 틀려 UPDATE로 고친 횟수(존 이름별)
  const std::map<std::string, int>& zone_fixes() const { return zone_fixes_; }

  wxtest::CardDb& db() { return db_; }

 private:
  void pull();
  void parse_request(const uint8_t* m, size_t len);
  void handle(int view, const uint8_t* m, size_t len);
  // 메시지 하나를 로그 줄로. 로그에 남기지 않는 메시지면 text가 빈 줄
  LogLine describe(int view, const uint8_t* m, size_t len);
  void add_log(int view, LogLine line);

  wxtest::CardDb& db_;
  wx_duel* duel_ = nullptr;
  std::optional<Request> req_;
  std::vector<LogLine> log_[4];
  std::string retry_[4];
  std::vector<ZoneMeta> zones_;
  FieldModel model_[3];  // P1·P2·관전
  bool remote_ = false, awaiting_ = false;
  int seat_ = 0;
  SendFn send_;
  std::optional<Request> no_request_;
  std::map<std::string, int> zone_fixes_;
  bool ended_ = false, practice_ = false;
  int winner_ = -1;
};

// 표시용 이름
const char* hint_name(uint32_t hint);
const char* phase_name(uint32_t phase);
std::string zone_label(const std::string& name);

}  // namespace wxframe
