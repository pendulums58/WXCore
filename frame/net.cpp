#include "net.h"

#include <event2/buffer.h>
#include <event2/bufferevent.h>
#include <event2/event.h>
#include <event2/listener.h>
#include <event2/util.h>

#ifdef _WIN32
#include <winsock2.h>
#include <ws2tcpip.h>
#else
#include <netdb.h>
#include <netinet/in.h>
#include <unistd.h>
#endif

#include <algorithm>
#include <cstring>
#include <utility>

namespace wxframe {

namespace {

constexpr uint32_t kMaxPacket = 16 * 1024 * 1024;  // 이보다 크면 깨진 연결로 본다

void startup() {
#ifdef _WIN32
  static bool done = false;
  if (!done) {
    WSADATA wsa;
    WSAStartup(MAKEWORD(2, 2), &wsa);
    done = true;
  }
#endif
}

}  // namespace

struct Net::Peer {
  Net* net;
  int id;
  bufferevent* bev;
};

Net::Net() {
  startup();
  base_ = event_base_new();
}

Net::~Net() {
  close_all();
  if (base_) event_base_free(base_);
}

int Net::add_peer(bufferevent* bev) {
  const int id = next_peer_++;
  Peer* p = new Peer{this, id, bev};
  peers_[id] = p;
  bufferevent_setcb(bev, on_read, nullptr, on_event, p);
  bufferevent_enable(bev, EV_READ | EV_WRITE);
  return id;
}

bool Net::listen(uint16_t port, std::string& err, bool local_only) {
  if (listener_) return true;
  sockaddr_in sin{};
  sin.sin_family = AF_INET;
  sin.sin_port = htons(port);
  sin.sin_addr.s_addr = htonl(local_only ? INADDR_LOOPBACK : INADDR_ANY);
  listener_ = evconnlistener_new_bind(
      base_,
      [](evconnlistener* l, evutil_socket_t fd, sockaddr* a, int len, void* user) {
        on_accept(l, static_cast<intptr_t>(fd), a, len, user);
      },
      this, LEV_OPT_CLOSE_ON_FREE | LEV_OPT_REUSEABLE, -1, reinterpret_cast<sockaddr*>(&sin), sizeof sin);
  if (!listener_) {
    err = "포트 " + std::to_string(port) + "를 열 수 없음(이미 쓰는 중일 수 있다)";
    return false;
  }
  return true;
}

void Net::on_accept(evconnlistener*, intptr_t fd, void*, int, void* user) {
  Net* net = static_cast<Net*>(user);
  bufferevent* bev = bufferevent_socket_new(net->base_, static_cast<evutil_socket_t>(fd), BEV_OPT_CLOSE_ON_FREE);
  Event e;
  e.kind = Event::Connected;
  e.peer = net->add_peer(bev);
  net->events_.push_back(std::move(e));
}

int Net::connect(const std::string& ip, uint16_t port, std::string& err) {
  sockaddr_storage ss{};
  int len = sizeof ss;
  const std::string addr = ip + ":" + std::to_string(port);
  if (evutil_parse_sockaddr_port(addr.c_str(), reinterpret_cast<sockaddr*>(&ss), &len) != 0) {
    err = "주소를 못 읽음: " + addr + "(숫자 IP로 적는다)";
    return 0;
  }
  bufferevent* bev = bufferevent_socket_new(base_, -1, BEV_OPT_CLOSE_ON_FREE);
  const int id = add_peer(bev);
  if (bufferevent_socket_connect(bev, reinterpret_cast<sockaddr*>(&ss), len) != 0) {
    err = "접속 시작 실패: " + addr;
    close(id);
    return 0;
  }
  return id;
}

void Net::on_read(bufferevent* bev, void* user) {
  Peer* p = static_cast<Peer*>(user);
  evbuffer* in = bufferevent_get_input(bev);
  for (;;) {
    const size_t have = evbuffer_get_length(in);
    if (have < 4) return;
    uint8_t head[4];
    evbuffer_copyout(in, head, 4);
    const uint32_t n = head[0] | (head[1] << 8) | (head[2] << 16) | (static_cast<uint32_t>(head[3]) << 24);
    if (n == 0 || n > kMaxPacket) {
      Event e;
      e.kind = Event::Closed;
      e.peer = p->id;
      Net* net = p->net;
      net->close(p->id);
      net->events_.push_back(std::move(e));
      return;
    }
    if (have < 4 + n) return;
    evbuffer_drain(in, 4);
    std::vector<uint8_t> data(n);
    evbuffer_remove(in, data.data(), n);
    Event e;
    e.kind = Event::Packet;
    e.peer = p->id;
    e.type = data[0];
    e.body.assign(data.begin() + 1, data.end());
    p->net->events_.push_back(std::move(e));
  }
}

void Net::on_event(bufferevent*, short what, void* user) {
  Peer* p = static_cast<Peer*>(user);
  Net* net = p->net;
  Event e;
  e.peer = p->id;
  if (what & BEV_EVENT_CONNECTED) {
    e.kind = Event::Connected;
    net->events_.push_back(std::move(e));
    return;
  }
  if (what & (BEV_EVENT_EOF | BEV_EVENT_ERROR)) {
    e.kind = Event::Closed;
    net->close(p->id);  // p를 지운다
    net->events_.push_back(std::move(e));
  }
}

void Net::poll() {
  if (base_) event_base_loop(base_, EVLOOP_NONBLOCK);
}

void Net::send(int peer, uint8_t type, const std::vector<uint8_t>& body) {
  auto it = peers_.find(peer);
  if (it == peers_.end()) return;
  const uint32_t n = static_cast<uint32_t>(body.size() + 1);
  uint8_t head[5] = {static_cast<uint8_t>(n), static_cast<uint8_t>(n >> 8), static_cast<uint8_t>(n >> 16),
                     static_cast<uint8_t>(n >> 24), type};
  bufferevent_write(it->second->bev, head, sizeof head);
  if (!body.empty()) bufferevent_write(it->second->bev, body.data(), body.size());
}

void Net::close(int peer) {
  auto it = peers_.find(peer);
  if (it == peers_.end()) return;
  bufferevent_free(it->second->bev);
  delete it->second;
  peers_.erase(it);
}

void Net::close_later(int peer) {
  auto it = peers_.find(peer);
  if (it == peers_.end()) return;
  bufferevent* bev = it->second->bev;
  bufferevent_disable(bev, EV_READ);
  if (evbuffer_get_length(bufferevent_get_output(bev)) == 0) {
    close(peer);
    return;
  }
  bufferevent_setwatermark(bev, EV_WRITE, 0, 0);
  // 다 나가면 on_drained에서 닫는다. 상대가 끊거나 5초 안에 못 보내도 닫는다
  bufferevent_setcb(bev, nullptr, on_drained, on_drain_failed, it->second);
  const timeval limit{5, 0};
  bufferevent_set_timeouts(bev, nullptr, &limit);
}

void Net::on_drain_failed(bufferevent*, short, void* user) {
  Peer* p = static_cast<Peer*>(user);
  p->net->close(p->id);
}

void Net::on_drained(bufferevent* bev, void* user) {
  if (evbuffer_get_length(bufferevent_get_output(bev)) != 0) return;
  Peer* p = static_cast<Peer*>(user);
  p->net->close(p->id);
}

void Net::close_all() {
  while (!peers_.empty()) close(peers_.begin()->first);
  if (listener_) evconnlistener_free(listener_);
  listener_ = nullptr;
}

std::vector<Net::Event> Net::take_events() { return std::exchange(events_, {}); }

UdpSocket::~UdpSocket() { close(); }

bool UdpSocket::open(uint16_t port, bool local_only, std::string& err) {
  startup();
  close();
  const evutil_socket_t s = socket(AF_INET, SOCK_DGRAM, 0);
  if (s == EVUTIL_INVALID_SOCKET) {
    err = "UDP 소켓을 만들 수 없음";
    return false;
  }
  evutil_make_socket_nonblocking(s);
  evutil_make_listen_socket_reuseable(s);
  int on = 1;
  setsockopt(s, SOL_SOCKET, SO_BROADCAST, reinterpret_cast<const char*>(&on), sizeof on);
  sockaddr_in sin{};
  sin.sin_family = AF_INET;
  sin.sin_port = htons(port);
  sin.sin_addr.s_addr = htonl(local_only ? INADDR_LOOPBACK : INADDR_ANY);
  if (bind(s, reinterpret_cast<sockaddr*>(&sin), sizeof sin) != 0) {
    evutil_closesocket(s);
    err = "UDP 포트 " + std::to_string(port) + "를 열 수 없음";
    return false;
  }
  fd_ = static_cast<intptr_t>(s);
  return true;
}

void UdpSocket::close() {
  if (fd_ != -1) evutil_closesocket(static_cast<evutil_socket_t>(fd_));
  fd_ = -1;
}

void UdpSocket::send_to(const std::string& ip, uint16_t port, const std::vector<uint8_t>& data) {
  if (fd_ == -1) return;
  sockaddr_in to{};
  to.sin_family = AF_INET;
  to.sin_port = htons(port);
  if (evutil_inet_pton(AF_INET, ip.c_str(), &to.sin_addr) != 1) return;
  sendto(static_cast<evutil_socket_t>(fd_), reinterpret_cast<const char*>(data.data()), static_cast<int>(data.size()), 0,
         reinterpret_cast<sockaddr*>(&to), sizeof to);
}

bool UdpSocket::recv(std::string& ip, uint16_t& port, std::vector<uint8_t>& data) {
  if (fd_ == -1) return false;
  uint8_t buf[2048];
  sockaddr_in from{};
  socklen_t len = sizeof from;
  const int n = static_cast<int>(recvfrom(static_cast<evutil_socket_t>(fd_), reinterpret_cast<char*>(buf), sizeof buf, 0,
                                          reinterpret_cast<sockaddr*>(&from), &len));
  if (n <= 0) return false;
  char addr[64] = "";
  evutil_inet_ntop(AF_INET, &from.sin_addr, addr, sizeof addr);
  ip = addr;
  port = ntohs(from.sin_port);
  data.assign(buf, buf + n);
  return true;
}

std::vector<std::string> local_ipv4() {
  startup();
  std::vector<std::string> out;
  char host[256] = "";
  if (gethostname(host, sizeof host) != 0) return out;
  addrinfo hints{};
  hints.ai_family = AF_INET;
  addrinfo* res = nullptr;
  if (getaddrinfo(host, nullptr, &hints, &res) != 0) return out;
  for (addrinfo* a = res; a; a = a->ai_next) {
    char buf[64] = "";
    evutil_inet_ntop(AF_INET, &reinterpret_cast<sockaddr_in*>(a->ai_addr)->sin_addr, buf, sizeof buf);
    const std::string ip = buf;
    if (!ip.empty() && ip.rfind("127.", 0) != 0 && std::find(out.begin(), out.end(), ip) == out.end()) out.push_back(ip);
  }
  freeaddrinfo(res);
  return out;
}

}  // namespace wxframe
