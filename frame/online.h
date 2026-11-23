#pragma once
// 온라인 대전(직접 IP·LAN). 방장 PC가 코어를 돌리고, 게스트에게는 게스트 뷰, 관전자에게는 관전 뷰(공개 정보만)
// 메시지만 보낸다(설계: 실행 위치, 정보 공개). CyanPro(EDOPro)의 방 대기 화면을 따른다: 준비·강퇴·관전·채팅.
// 화면이 없어도 돌아가므로 러너가 같은 프로세스 안에서 방장·게스트·관전자를 띄워 검사한다.
//
// 패킷(참가자 → 방장)                              패킷(방장 → 참가자)
//   kJoin       u32 프로토콜, u32 스키마,              kWelcome    u8 역할(1 대전자, 2 관전)
//               str 이름, str 비밀번호, u8 관전 희망   kRoom       방 상태(RoomState 순서대로)
//   kDeck       str 덱 파일 내용(JSON)                 kStart      u8 뷰(대전자 1, 관전 2)
//   kReady      u8 준비                                kMessages   메시지들(코어 메시지 + UPDATE)
//   kResponse   u32 개수, u32 값...                    kError      str 이유(보낸 뒤 끊는다)
//   kCancel                                            kBackToRoom 대전을 끝내고 방으로
//   kChat       str 내용                               kChat       str 이름, str 내용
//   kToSpectator / kToDuelist
#include <cstdint>
#include <string>
#include <vector>

#include "card_db.h"
#include "game.h"
#include "net.h"

namespace wxframe {

constexpr uint32_t kProtocol = 4;  // 3: 덱 파일이 cid 형식, 4: 판본(UPDATE의 print)
constexpr uint16_t kDefaultPort = 7911;
constexpr uint16_t kLanPort = 7910;  // 방 찾기(UDP)

enum Packet : uint8_t {
  kJoin = 1,
  kDeck = 2,
  kResponse = 3,
  kCancel = 4,
  kReady = 5,
  kChat = 6,
  kToSpectator = 7,
  kToDuelist = 8,
  kWelcome = 0x81,
  kRoom = 0x82,
  kStart = 0x83,
  kMessages = 0x84,
  kError = 0x85,
  kBackToRoom = 0x86,
  kChatOut = 0x87,
};

// 모두에게 보이는 방 상태
struct RoomState {
  std::string room_name, host_name, guest_name;  // guest_name이 비면 P2 자리가 빔
  bool guest_ready = false, guest_deck_ok = false;
  std::vector<std::string> guest_problems;
  std::vector<std::string> spectators;
  bool in_duel = false, check_decks = true, locked = false;
};

struct ChatLine {
  std::string name, text;
};

class OnlineHost {
 public:
  OnlineHost(wxtest::CardDb& db, Game& game) : db_(db), game_(game) {}
  // local_only면 127.0.0.1만(검사용, 방화벽 창이 안 뜬다). LAN 방 찾기 응답도 같이 연다
  bool open(uint16_t port, const std::string& name, const std::string& room_name, const std::string& password,
            std::string& err, bool local_only = false, uint16_t lan_port = kLanPort);
  void close();
  bool is_open() const { return net_.listening(); }
  void poll();  // 프레임마다. 접속·패킷 처리, 대전 메시지 보내기

  const RoomState& room() const { return room_; }
  bool has_guest() const { return guest_ != 0; }
  bool can_start() const;
  void set_check_decks(bool on);
  void kick_guest();
  void kick_spectator(size_t index);
  void chat(const std::string& text);
  const std::vector<ChatLine>& chat_log() const { return chat_; }
  uint64_t chat_count() const { return chat_count_; }  // 지금까지 받은 줄 수(기록은 200줄까지만 남는다)

  // 방장 덱으로 대전을 시작한다. 방장이 P1 자리(0), 게스트가 P2 자리(1). 선공은 코어가 정한다
  bool start(const wxtest::DeckFile& mine, uint64_t seed, std::string& err);
  void back_to_room();
  std::string status;  // 화면에 보일 마지막 일

 private:
  struct Member {
    int peer = 0;
    std::string name;
    bool joined = false;
  };
  void on_packet(const Net::Event& e);
  void flush();
  void send_room();
  void broadcast(uint8_t type, const std::vector<uint8_t>& body);
  void drop(int peer, const std::string& why);
  void add_chat(const std::string& name, const std::string& text);
  Member* member(int peer);
  void start_spectator(int peer);

  wxtest::CardDb& db_;
  Game& game_;
  Net net_;
  UdpSocket lan_;  // LAN 방 찾기에 답한다
  std::string password_;
  uint16_t net_port_ = 0;
  RoomState room_;
  std::vector<Member> members_;  // 접속한 모든 사람(게스트·관전·아직 들어오는 중)
  int guest_ = 0;                // P2 자리 peer
  std::vector<int> spectators_;
  bool deck_loaded_ = false;
  wxtest::DeckFile guest_deck_;
  std::vector<uint8_t> pending_[3];  // 뷰마다 아직 안 보낸 메시지(1 게스트, 2 관전)
  std::vector<uint8_t> history_;     // 관전 뷰 전체(중간에 들어온 관전자에게)
  std::vector<ChatLine> chat_;
  uint64_t chat_count_ = 0;
};

class OnlineGuest {
 public:
  OnlineGuest(wxtest::CardDb& db, Game& game) : db_(db), game_(game) {}
  bool connect(const std::string& ip, uint16_t port, const std::string& name, const std::string& password,
               bool spectate, std::string& err);
  void close();
  void poll();
  void send_deck(const std::string& deck_json);
  void set_ready(bool on);
  void chat(const std::string& text);
  void to_spectator();
  void to_duelist();

  bool connected() const { return peer_ != 0 && connected_; }
  bool connecting() const { return peer_ != 0 && !connected_; }
  bool joined() const { return role_ != 0; }
  bool spectating() const { return role_ == 2; }
  bool ready() const { return ready_; }
  const RoomState& room() const { return room_; }
  const std::vector<ChatLine>& chat_log() const { return chat_; }
  uint64_t chat_count() const { return chat_count_; }  // 지금까지 받은 줄 수(기록은 200줄까지만 남는다)
  std::string status;

 private:
  void on_packet(const Net::Event& e);

  wxtest::CardDb& db_;
  Game& game_;
  Net net_;
  int peer_ = 0;
  int role_ = 0;  // 0 아직, 1 대전자, 2 관전
  bool connected_ = false, ready_ = false, spectate_ = false;
  std::string name_, password_, deck_json_;
  RoomState room_;
  std::vector<ChatLine> chat_;
  uint64_t chat_count_ = 0;
};

// LAN 방 찾기 결과 한 줄
struct LanRoom {
  std::string ip;
  uint16_t port = 0;
  std::string room_name, host_name;
  int players = 1;
  bool in_duel = false, locked = false;
};

// 게스트 쪽: UDP로 「방 있어?」를 보내고 답을 모은다
class LanFinder {
 public:
  LanFinder();
  ~LanFinder();
  // 브로드캐스트(255.255.255.255)와 extra로 묻는다. local_only면 127.0.0.1 소켓으로 extra에만(검사용)
  bool search(std::string& err, uint16_t lan_port = kLanPort, const std::vector<std::string>& extra = {},
              bool local_only = false);
  void poll();
  const std::vector<LanRoom>& rooms() const { return rooms_; }

 private:
  UdpSocket sock_;
  std::vector<LanRoom> rooms_;
};

}  // namespace wxframe
