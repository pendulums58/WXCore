#pragma once
// 네트워크(libevent, CyanPro/EDOPro와 같은 라이브러리). 프레임 루프에서 poll()을 불러 막히지 않고 돈다(단일 스레드).
// 패킷: u32 길이(종류 + 본문) + u8 종류 + 본문
#include <cstdint>
#include <map>
#include <string>
#include <vector>

struct event_base;
struct evconnlistener;
struct bufferevent;

namespace wxframe {

class Net {
 public:
  struct Event {
    enum Kind { Connected, Packet, Closed } kind = Packet;
    int peer = 0;
    uint8_t type = 0;
    std::vector<uint8_t> body;
  };

  Net();
  ~Net();
  Net(const Net&) = delete;
  Net& operator=(const Net&) = delete;

  // 방장: 이 포트에서 접속을 받는다. local_only면 이 PC 안(127.0.0.1)만(검사용, 방화벽 창이 안 뜬다)
  bool listen(uint16_t port, std::string& err, bool local_only = false);
  // 게스트: 접속을 시작한다(끝나면 Connected 또는 Closed 이벤트). ip는 숫자 주소
  int connect(const std::string& ip, uint16_t port, std::string& err);
  // 쌓인 일을 처리한다. 막히지 않는다
  void poll();
  void send(int peer, uint8_t type, const std::vector<uint8_t>& body);
  void close(int peer);
  // 보낼 것을 다 보낸 뒤 끊는다(오류를 알리고 끊을 때). 더는 이벤트가 오지 않는다
  void close_later(int peer);
  void close_all();
  std::vector<Event> take_events();
  bool listening() const { return listener_ != nullptr; }

 private:
  struct Peer;
  int add_peer(bufferevent* bev);
  static void on_accept(evconnlistener*, intptr_t fd, void* addr, int len, void* user);
  static void on_read(bufferevent* bev, void* user);
  static void on_event(bufferevent* bev, short what, void* user);
  static void on_drained(bufferevent* bev, void* user);
  static void on_drain_failed(bufferevent* bev, short what, void* user);

  event_base* base_ = nullptr;
  evconnlistener* listener_ = nullptr;
  std::map<int, Peer*> peers_;
  int next_peer_ = 1;
  std::vector<Event> events_;
};

// UDP 소켓(LAN 방 찾기). 논블로킹이라 poll에서 recv를 돌린다
class UdpSocket {
 public:
  UdpSocket() = default;
  ~UdpSocket();
  UdpSocket(const UdpSocket&) = delete;
  UdpSocket& operator=(const UdpSocket&) = delete;
  // port 0이면 아무 포트. local_only면 127.0.0.1에만
  bool open(uint16_t port, bool local_only, std::string& err);
  void close();
  bool is_open() const { return fd_ != -1; }
  void send_to(const std::string& ip, uint16_t port, const std::vector<uint8_t>& data);
  // 받은 것이 있으면 true
  bool recv(std::string& ip, uint16_t& port, std::vector<uint8_t>& data);

 private:
  intptr_t fd_ = -1;
};

// 이 PC의 IPv4 주소(방장이 게스트에게 알려 줄 것). 루프백 제외
std::vector<std::string> local_ipv4();

// 패킷 본문 쓰기·읽기(리틀엔디언, 문자열은 u16 길이 + 바이트)
struct PacketWriter {
  std::vector<uint8_t> b;
  PacketWriter& u8(uint32_t v) { return put(v, 1); }
  PacketWriter& u16(uint32_t v) { return put(v, 2); }
  PacketWriter& u32(uint32_t v) { return put(v, 4); }
  PacketWriter& str(const std::string& s) {
    const size_t n = s.size() < 0xFFFF ? s.size() : 0xFFFF;  // 길이가 u16이라 넘치면 자른다
    u16(static_cast<uint32_t>(n));
    b.insert(b.end(), s.begin(), s.begin() + static_cast<std::ptrdiff_t>(n));
    return *this;
  }
  PacketWriter& bytes(const std::vector<uint8_t>& v) {
    b.insert(b.end(), v.begin(), v.end());
    return *this;
  }
  PacketWriter& put(uint32_t v, int n) {
    for (int i = 0; i < n; ++i) b.push_back(static_cast<uint8_t>(v >> (8 * i)));
    return *this;
  }
};

struct PacketReader {
  const std::vector<uint8_t>& b;
  size_t pos = 0;
  bool ok = true;
  uint32_t get(int n) {
    uint32_t v = 0;
    for (int i = 0; i < n; ++i) {
      if (pos >= b.size()) {
        ok = false;
        return v;
      }
      v |= static_cast<uint32_t>(b[pos++]) << (8 * i);
    }
    return v;
  }
  uint32_t u8() { return get(1); }
  uint32_t u16() { return get(2); }
  uint32_t u32() { return get(4); }
  std::string str() {
    const uint32_t n = u16();
    if (pos + n > b.size()) {
      ok = false;
      return {};
    }
    std::string s(b.begin() + static_cast<std::ptrdiff_t>(pos), b.begin() + static_cast<std::ptrdiff_t>(pos + n));
    pos += n;
    return s;
  }
};

}  // namespace wxframe
