#pragma once
// 온라인 대전(직접 IP). 방장 PC가 코어를 돌리고, 게스트에게는 게스트 뷰 메시지만 보낸다(설계: 실행 위치).
// 화면이 없어도 돌아가므로 러너가 같은 프로세스 안에서 방장·게스트를 띄워 검사한다.
//
// 패킷(게스트 → 방장)                         패킷(방장 → 게스트)
//   kJoin     u32 프로토콜, u32 스키마, str 이름   kWelcome  str 방장 이름
//   kDeck     str 덱 파일 내용(JSON)             kRoom     str 게스트 덱 문제(줄바꿈으로 이음, 빈 문자열이면 통과)
//   kResponse u32 개수, u32 값...               kStart    u8 자리(게스트는 1)
//   kCancel                                     kMessages 메시지들(코어 메시지 + UPDATE, 게스트 뷰)
//                                               kError    str 이유(보낸 뒤 끊는다)
//                                               kBackToRoom 대전을 끝내고 방으로
#include <cstdint>
#include <string>
#include <vector>

#include "card_db.h"
#include "game.h"
#include "net.h"

namespace wxframe {

constexpr uint32_t kProtocol = 1;
constexpr uint16_t kDefaultPort = 7911;

enum Packet : uint8_t {
  kJoin = 1,
  kDeck = 2,
  kResponse = 3,
  kCancel = 4,
  kWelcome = 0x81,
  kRoom = 0x82,
  kStart = 0x83,
  kMessages = 0x84,
  kError = 0x85,
  kBackToRoom = 0x86,
};

class OnlineHost {
 public:
  OnlineHost(wxtest::CardDb& db, Game& game) : db_(db), game_(game) {}
  bool open(uint16_t port, const std::string& name, std::string& err, bool local_only = false);
  void close();
  bool is_open() const { return net_.listening(); }
  void poll();  // 프레임마다. 접속·패킷 처리, 대전 메시지 보내기

  bool has_guest() const { return guest_ != 0 && joined_; }
  const std::string& guest_name() const { return guest_name_; }
  bool guest_deck_ready() const { return deck_loaded_; }
  const wxtest::DeckFile& guest_deck() const { return guest_deck_; }
  const std::vector<std::string>& guest_problems() const { return guest_problems_; }
  bool check_decks = true;  // 끄면 덱 검사 문제가 있어도 시작할 수 있다(CyanPro 「덱 검사 안 함」)
  bool can_start() const { return has_guest() && deck_loaded_ && (!check_decks || guest_problems_.empty()); }

  // 방장 덱으로 대전을 시작한다. 방장이 P1 자리(0), 게스트가 P2 자리(1). 선공은 코어가 정한다
  bool start(const wxtest::DeckFile& mine, uint64_t seed, std::string& err);
  void back_to_room();
  std::string status;  // 화면에 보일 마지막 일

 private:
  void on_packet(const Net::Event& e);
  void flush();

  wxtest::CardDb& db_;
  Game& game_;
  Net net_;
  int guest_ = 0;
  bool joined_ = false, deck_loaded_ = false;
  std::string name_, guest_name_;
  wxtest::DeckFile guest_deck_;
  std::vector<std::string> guest_problems_;
  std::vector<uint8_t> pending_;  // 게스트 뷰로 나갈 메시지
};

class OnlineGuest {
 public:
  OnlineGuest(wxtest::CardDb& db, Game& game) : db_(db), game_(game) {}
  bool connect(const std::string& ip, uint16_t port, const std::string& name, std::string& err);
  void close();
  void poll();
  void send_deck(const std::string& deck_json);

  bool connected() const { return peer_ != 0 && connected_; }
  bool joined() const { return !host_name_.empty(); }
  bool connecting() const { return peer_ != 0 && !connected_; }
  const std::string& host_name() const { return host_name_; }
  const std::vector<std::string>& deck_problems() const { return deck_problems_; }
  bool deck_checked() const { return deck_checked_; }
  std::string status;

 private:
  void on_packet(const Net::Event& e);

  wxtest::CardDb& db_;
  Game& game_;
  Net net_;
  int peer_ = 0;
  bool connected_ = false, deck_checked_ = false;
  std::string name_, host_name_, deck_json_;
  std::vector<std::string> deck_problems_;
};

}  // namespace wxframe
