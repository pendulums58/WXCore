// 온라인 방 화면(CyanPro의 LAN 창·방 대기 화면을 줄인 것). 직접 IP로 접속한다.
//   방 만들기: 이름·포트 → 방 열기 → 내 IP를 알려 주고 게스트를 기다림 → 덱이 준비되면 대전 시작
//   참가: 이름·IP·포트·덱 → 접속 → 방장이 시작하기를 기다림
#include <imgui.h>

#include <random>

#include "deck_check.h"
#include "view.h"

namespace wxframe {

namespace {

void problems_list(const std::vector<std::string>& problems) {
  if (problems.empty()) {
    ImGui::TextColored(ImVec4(0.5f, 0.9f, 0.5f, 1), "덱 검사 통과");
    return;
  }
  for (const auto& p : problems) ImGui::TextColored(ImVec4(1, 0.5f, 0.4f, 1), "· %s", p.c_str());
}

}  // namespace

void App::dev_host(int port) {
  reload_deck_list();
  port_ = port;
  std::snprintf(nick_, sizeof nick_, "방장");
  host_ = std::make_unique<OnlineHost>(db_, game_);
  if (!host_->open(static_cast<uint16_t>(port), nick_, online_error_, true)) host_.reset();
  screen_ = Screen::Host;
  dev_auto_start_ = true;
}

void App::dev_join(const std::string& ip, int port) {
  reload_deck_list();
  std::snprintf(nick_, sizeof nick_, "게스트");
  std::snprintf(ip_, sizeof ip_, "%s", ip.c_str());
  port_ = port;
  online_deck_ = decks_.size() > 1 ? 1 : 0;
  guest_ = std::make_unique<OnlineGuest>(db_, game_);
  std::string text;
  if (guest_->connect(ip, static_cast<uint16_t>(port), nick_, online_error_) &&
      wxtest::read_deck_text(wxtest::data_dir() + "/decks/" + decks_[online_deck_] + ".json", text))
    guest_->send_deck(text);
  screen_ = Screen::Join;
}

bool App::online() const { return (host_ && host_->is_open()) || (guest_ && (guest_->connected() || guest_->connecting())); }

void App::leave_online() {
  if (host_) host_->close();
  if (guest_) guest_->close();
  host_.reset();
  guest_.reset();
}

void App::poll_online() {
  if (host_) host_->poll();
  if (guest_) guest_->poll();
}

bool App::deck_combo(const char* id, int& index) {
  bool changed = false;
  const char* cur = index < static_cast<int>(decks_.size()) ? decks_[index].c_str() : "";
  ImGui::SetNextItemWidth(260);
  if (ImGui::BeginCombo(id, cur)) {
    for (int i = 0; i < static_cast<int>(decks_.size()); ++i)
      if (ImGui::Selectable(decks_[i].c_str(), i == index)) {
        index = i;
        changed = true;
      }
    ImGui::EndCombo();
  }
  return changed;
}

void App::draw_host(ImVec2 size) {
  ImGui::SetNextWindowPos(ImVec2(size.x * 0.5f, size.y * 0.5f), ImGuiCond_Always, ImVec2(0.5f, 0.5f));
  ImGui::Begin("방 만들기", nullptr, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoMove);
  if (!host_ || !host_->is_open()) {
    ImGui::SetNextItemWidth(200);
    ImGui::InputText("이름", nick_, sizeof nick_);
    ImGui::SetNextItemWidth(200);
    ImGui::InputInt("포트", &port_);
    if (ImGui::Button("방 열기", ImVec2(140, 0))) {
      host_ = std::make_unique<OnlineHost>(db_, game_);
      online_error_.clear();
      if (!host_->open(static_cast<uint16_t>(port_), nick_, online_error_)) host_.reset();
    }
    ImGui::SameLine();
    if (ImGui::Button("메뉴로", ImVec2(140, 0))) screen_ = Screen::Menu;
    if (!online_error_.empty()) ImGui::TextColored(ImVec4(1, 0.4f, 0.4f, 1), "%s", online_error_.c_str());
    ImGui::End();
    return;
  }
  ImGui::TextUnformatted(host_->status.c_str());
  std::string ips;
  for (const auto& ip : local_ipv4()) ips += (ips.empty() ? "" : ", ") + ip;
  ImGui::TextDisabled("내 IP: %s  포트 %d", ips.empty() ? "?" : ips.c_str(), port_);
  ImGui::TextDisabled("인터넷 너머라면 포트포워딩이나 가상 LAN(Radmin·Hamachi 등)이 필요하다");
  ImGui::Separator();

  ImGui::Text("P1 %s(나)", nick_);
  ImGui::SameLine();
  deck_combo("##mydeck", online_deck_);
  if (my_deck_cached_ != online_deck_) {
    my_deck_cached_ = online_deck_;
    my_deck_ = wxtest::DeckFile{};
    my_deck_problems_.clear();
    std::string err;
    my_deck_loaded_ = online_deck_ < static_cast<int>(decks_.size()) &&
                      wxtest::load_deck(wxtest::data_dir() + "/decks/" + decks_[online_deck_] + ".json", db_, my_deck_, err);
    if (my_deck_loaded_) {
      const wxtest::DeckCheck c = wxtest::check_deck(db_, my_deck_);
      my_deck_problems_ = c.problems;
      if (!c.error.empty()) my_deck_problems_.push_back("검사 오류: " + c.error);
    } else {
      my_deck_problems_.push_back(err);
    }
  }
  problems_list(my_deck_problems_);
  ImGui::Separator();

  if (host_->has_guest()) {
    ImGui::Text("P2 %s", host_->guest_name().c_str());
    if (host_->guest_deck_ready() || !host_->guest_problems().empty()) problems_list(host_->guest_problems());
    else ImGui::TextDisabled("덱을 기다리는 중");
  } else {
    ImGui::TextDisabled("P2 (비어 있음)");
  }
  ImGui::Separator();
  ImGui::Checkbox("덱 검사(끄면 문제가 있어도 시작)", &host_->check_decks);
  const bool my_ok = my_deck_loaded_ && (!host_->check_decks || my_deck_problems_.empty());
  ImGui::BeginDisabled(!host_->can_start() || !my_ok);
  const bool auto_start = dev_auto_start_ && host_->can_start() && my_ok;
  if (ImGui::Button("대전 시작", ImVec2(140, 0)) || auto_start) {
    dev_auto_start_ = false;
    std::random_device rd;
    const uint64_t seed = (static_cast<uint64_t>(rd()) << 32) | rd();
    online_error_.clear();
    if (host_->start(my_deck_, seed, online_error_)) {
      viewer_ = 0;  // 방장은 P1 자리
      follow_ = false;
      pass_screen_ = false;
      pass_to_ = -1;
      picks_.clear();
      open_zone_ = -1;
    }
  }
  ImGui::EndDisabled();
  ImGui::SameLine();
  if (ImGui::Button("방 닫기", ImVec2(140, 0))) {
    leave_online();
    screen_ = Screen::Menu;
  }
  if (!online_error_.empty()) ImGui::TextColored(ImVec4(1, 0.4f, 0.4f, 1), "%s", online_error_.c_str());
  ImGui::End();
}

void App::draw_join(ImVec2 size) {
  ImGui::SetNextWindowPos(ImVec2(size.x * 0.5f, size.y * 0.5f), ImGuiCond_Always, ImVec2(0.5f, 0.5f));
  ImGui::Begin("참가", nullptr, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoMove);
  auto send_my_deck = [&] {
    std::string text;
    if (guest_ && online_deck_ < static_cast<int>(decks_.size()) &&
        wxtest::read_deck_text(wxtest::data_dir() + "/decks/" + decks_[online_deck_] + ".json", text))
      guest_->send_deck(text);
  };
  const bool active = guest_ && (guest_->connected() || guest_->connecting());
  if (!active) {
    ImGui::SetNextItemWidth(200);
    ImGui::InputText("이름", nick_, sizeof nick_);
    ImGui::SetNextItemWidth(200);
    ImGui::InputText("방장 IP", ip_, sizeof ip_);
    ImGui::SetNextItemWidth(200);
    ImGui::InputInt("포트", &port_);
    ImGui::TextUnformatted("덱");
    ImGui::SameLine();
    deck_combo("##joindeck", online_deck_);
    if (ImGui::Button("접속", ImVec2(140, 0))) {
      if (!guest_) guest_ = std::make_unique<OnlineGuest>(db_, game_);
      online_error_.clear();
      if (guest_->connect(ip_, static_cast<uint16_t>(port_), nick_, online_error_)) send_my_deck();
    }
    ImGui::SameLine();
    if (ImGui::Button("메뉴로", ImVec2(140, 0))) {
      leave_online();
      screen_ = Screen::Menu;
    }
    if (guest_ && !guest_->status.empty()) ImGui::TextDisabled("%s", guest_->status.c_str());
    if (!online_error_.empty()) ImGui::TextColored(ImVec4(1, 0.4f, 0.4f, 1), "%s", online_error_.c_str());
    ImGui::End();
    return;
  }
  ImGui::TextUnformatted(guest_->status.c_str());
  if (guest_->joined()) {
    ImGui::Text("방장: %s", guest_->host_name().c_str());
    ImGui::TextUnformatted("덱");
    ImGui::SameLine();
    if (deck_combo("##joindeck2", online_deck_)) send_my_deck();
    if (guest_->deck_checked()) problems_list(guest_->deck_problems());
    else ImGui::TextDisabled("방장이 덱을 검사하는 중");
    ImGui::TextDisabled("방장이 대전을 시작하기를 기다리는 중");
  }
  if (ImGui::Button("나가기", ImVec2(140, 0))) {
    leave_online();
    screen_ = Screen::Menu;
  }
  ImGui::End();
}

}  // namespace wxframe
