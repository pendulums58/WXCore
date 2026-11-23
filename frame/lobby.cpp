// 온라인 방 화면. CyanPro(EDOPro)의 LAN 창·방 만들기·방 대기 화면을 따른다.
//   방 만들기: 이름·방 이름·비밀번호·포트 → 방 열기 → 대기 화면
//   참가: LAN 방 목록(또는 IP 직접) → 접속 → 대기 화면
//   대기 화면: P1·P2 칸(덱 검사, 준비, 강퇴), 관전자, 덱 검사 설정, 채팅, 대전 시작
#include <imgui.h>

#include <algorithm>
#include <random>

#include "deck_check.h"
#include "view.h"

namespace wxframe {

namespace {

const ImVec4 kGood(0.5f, 0.9f, 0.5f, 1), kBad(1, 0.5f, 0.4f, 1), kWarn(1, 0.8f, 0.3f, 1);

void problems_list(const std::vector<std::string>& problems) {
  if (problems.empty()) {
    ImGui::TextColored(kGood, "덱 검사 통과");
    return;
  }
  for (const auto& p : problems) ImGui::TextColored(kBad, "· %s", p.c_str());
}

}  // namespace

void App::dev_host(int port) {
  reload_deck_list();
  port_ = port;
  std::snprintf(nick_, sizeof nick_, "방장");
  host_ = std::make_unique<OnlineHost>(db_, game_);
  if (!host_->open(static_cast<uint16_t>(port), nick_, "", "", online_error_, true, static_cast<uint16_t>(port + 1)))
    host_.reset();
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
  if (guest_->connect(ip, static_cast<uint16_t>(port), nick_, "", false, online_error_) &&
      wxtest::read_deck_text(wxtest::data_dir() + "/decks/" + decks_[online_deck_] + ".json", text))
    guest_->send_deck(text);
  dev_auto_start_ = true;  // 게스트는 덱 검사가 끝나면 바로 준비
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
  if (finder_) finder_->poll();
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

void App::draw_chat(float height) {
  const std::vector<ChatLine>* log = host_ ? &host_->chat_log() : guest_ ? &guest_->chat_log() : nullptr;
  ImGui::BeginChild("chat_log", ImVec2(0, height), ImGuiChildFlags_Borders);
  if (log)
    for (const auto& c : *log) {
      ImGui::TextColored(ImVec4(0.55f, 0.8f, 1.0f, 1), "%s:", c.name.c_str());
      ImGui::SameLine();
      ImGui::PushTextWrapPos(0.0f);
      ImGui::TextUnformatted(c.text.c_str());
      ImGui::PopTextWrapPos();
    }
  if (ImGui::GetScrollY() >= ImGui::GetScrollMaxY() - 4) ImGui::SetScrollHereY(1.0f);  // 맨 아래를 보고 있으면 따라간다
  ImGui::EndChild();
  chat_input(-1);
}

bool App::chat_input(float width) {
  // Enter로 보낸 뒤에도 입력 칸에 남는다(YGOPro·CyanPro). 입력 칸 밖에서 Enter를 누르면 입력 칸으로
  if (chat_refocus_ || (!ImGui::GetIO().WantTextInput && ImGui::IsKeyPressed(ImGuiKey_Enter, false))) {
    ImGui::SetKeyboardFocusHere();
    chat_refocus_ = false;
  }
  const bool can = online();
  ImGui::BeginDisabled(!can);
  ImGui::SetNextItemWidth(width);
  const bool enter = ImGui::InputTextWithHint("##chat", can ? "Enter로 보내기" : "채팅은 온라인 대전에서",
                                              chat_input_, sizeof chat_input_, ImGuiInputTextFlags_EnterReturnsTrue);
  ImGui::EndDisabled();
  if (!enter) return false;
  chat_refocus_ = true;
  if (!chat_input_[0]) return false;
  if (host_) host_->chat(chat_input_);
  else if (guest_) guest_->chat(chat_input_);
  chat_input_[0] = 0;
  return true;
}

void App::sync_chat() {
  // 온라인 채팅: 기록은 200줄에서 잘리므로 받은 줄 수로 새 줄을 센다
  const std::vector<ChatLine>* log = host_ ? &host_->chat_log() : guest_ ? &guest_->chat_log() : nullptr;
  const uint64_t total = host_ ? host_->chat_count() : guest_ ? guest_->chat_count() : 0;
  if (total < chat_seen_) chat_seen_ = 0;  // 방을 새로 열었다
  if (log && total > chat_seen_) {
    const size_t n = static_cast<size_t>(std::min<uint64_t>(total - chat_seen_, log->size()));
    for (size_t i = log->size() - n; i < log->size(); ++i) chat_view_.push_back({(*log)[i].name, (*log)[i].text, false});
  }
  chat_seen_ = total;
  // 코어·스크립트 오류(대전 로그의 오류 줄). 새 대전이면 로그가 비워져 다시 센다
  size_t errors = 0;
  for (const auto& l : game_.log(WX_VIEW_ALL)) {
    if (l.kind != LogLine::Error) continue;
    if (++errors <= error_seen_) continue;
    if (!chat_view_.empty() && chat_view_.back().error && chat_view_.back().text == l.text) ++chat_view_.back().count;
    else chat_view_.push_back({"오류", l.text, true});
  }
  error_seen_ = errors;
  if (chat_view_.size() > 300) chat_view_.erase(chat_view_.begin(), chat_view_.end() - 300);
}

void App::draw_chat_bar(ImVec2 pos, ImVec2 size) {
  sync_chat();
  ImGui::SetNextWindowPos(pos);
  ImGui::SetNextWindowSize(size);
  ImGui::PushStyleColor(ImGuiCol_WindowBg, IM_COL32(12, 14, 22, 255));
  ImGui::Begin("채팅", nullptr,
               ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoCollapse |
                   ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoBringToFrontOnFocus);
  ImGui::PopStyleColor();
  ImGui::BeginChild("chat_lines", ImVec2(0, ImGui::GetContentRegionAvail().y - ImGui::GetFrameHeightWithSpacing()));
  for (const auto& c : chat_view_) {
    if (c.error) {
      ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(1.0f, 0.45f, 0.45f, 1));
      ImGui::PushTextWrapPos(0.0f);
      if (c.count > 1) ImGui::Text("%s  ×%d", c.text.c_str(), c.count);
      else ImGui::TextUnformatted(c.text.c_str());
      ImGui::PopTextWrapPos();
      ImGui::PopStyleColor();
      continue;
    }
    ImGui::TextColored(ImVec4(0.55f, 0.8f, 1.0f, 1), "%s:", c.name.c_str());
    ImGui::SameLine();
    ImGui::PushTextWrapPos(0.0f);
    ImGui::TextUnformatted(c.text.c_str());
    ImGui::PopTextWrapPos();
  }
  if (ImGui::GetScrollY() >= ImGui::GetScrollMaxY() - 4) ImGui::SetScrollHereY(1.0f);  // 맨 아래를 보고 있으면 따라간다
  ImGui::EndChild();
  chat_input(-1);
  ImGui::End();
}

void App::draw_host(ImVec2 size) {
  if (host_ && host_->is_open()) {
    draw_room(size);
    return;
  }
  ImGui::SetNextWindowPos(ImVec2(size.x * 0.5f, size.y * 0.5f), ImGuiCond_Always, ImVec2(0.5f, 0.5f));
  ImGui::Begin("방 만들기", nullptr, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoMove);
  ImGui::SetNextItemWidth(220);
  ImGui::InputText("이름", nick_, sizeof nick_);
  ImGui::SetNextItemWidth(220);
  ImGui::InputTextWithHint("방 이름", "비우면 「이름의 방」", room_name_, sizeof room_name_);
  ImGui::SetNextItemWidth(220);
  ImGui::InputTextWithHint("비밀번호", "비우면 누구나", password_, sizeof password_);
  ImGui::SetNextItemWidth(220);
  ImGui::InputInt("포트", &port_);
  if (ImGui::Button("방 열기", ImVec2(140, 0))) {
    host_ = std::make_unique<OnlineHost>(db_, game_);
    online_error_.clear();
    my_deck_cached_ = -1;
    if (!host_->open(static_cast<uint16_t>(port_), nick_, room_name_, password_, online_error_)) host_.reset();
  }
  ImGui::SameLine();
  if (ImGui::Button("메뉴로", ImVec2(140, 0))) screen_ = Screen::Menu;
  if (!online_error_.empty()) ImGui::TextColored(kBad, "%s", online_error_.c_str());
  ImGui::End();
}

void App::draw_join(ImVec2 size) {
  if (guest_ && guest_->joined() && (guest_->connected() || guest_->connecting())) {
    draw_room(size);
    return;
  }
  ImGui::SetNextWindowPos(ImVec2(size.x * 0.5f, size.y * 0.5f), ImGuiCond_Always, ImVec2(0.5f, 0.5f));
  ImGui::SetNextWindowSize(ImVec2(620, 0));
  ImGui::Begin("참가", nullptr, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoMove);
  ImGui::SetNextItemWidth(220);
  ImGui::InputText("이름", nick_, sizeof nick_);
  // LAN 방 목록
  ImGui::SeparatorText("같은 네트워크의 방");
  if (!finder_) {
    finder_ = std::make_unique<LanFinder>();
    finder_->search(online_error_);
  }
  if (ImGui::Button("다시 찾기")) {
    online_error_.clear();
    finder_->search(online_error_);
  }
  ImGui::BeginChild("rooms", ImVec2(0, 160), ImGuiChildFlags_Borders);
  if (finder_->rooms().empty()) ImGui::TextDisabled("찾은 방이 없다(방화벽이 막았거나 다른 네트워크일 수 있다. 아래에 IP를 직접 적는다)");
  for (const auto& r : finder_->rooms()) {
    char label[256];
    std::snprintf(label, sizeof label, "%s%s  (%s)  %d/2%s  %s:%u", r.locked ? "[잠김] " : "", r.room_name.c_str(), r.host_name.c_str(),
                  r.players, r.in_duel ? "  대전 중" : "", r.ip.c_str(), r.port);
    if (ImGui::Selectable(label)) {
      std::snprintf(ip_, sizeof ip_, "%s", r.ip.c_str());
      port_ = r.port;
      join_spectate_ = r.players >= 2 || r.in_duel;
    }
  }
  ImGui::EndChild();
  ImGui::SeparatorText("접속");
  ImGui::SetNextItemWidth(220);
  ImGui::InputText("방장 IP", ip_, sizeof ip_);
  ImGui::SetNextItemWidth(220);
  ImGui::InputInt("포트", &port_);
  ImGui::SetNextItemWidth(220);
  ImGui::InputText("비밀번호", password_, sizeof password_);
  ImGui::Checkbox("관전으로 들어가기", &join_spectate_);
  ImGui::TextUnformatted("덱");
  ImGui::SameLine();
  deck_combo("##joindeck", online_deck_);
  const bool busy = guest_ && guest_->connecting();
  ImGui::BeginDisabled(busy);
  if (ImGui::Button(busy ? "접속하는 중" : "접속", ImVec2(140, 0))) {
    if (!guest_) guest_ = std::make_unique<OnlineGuest>(db_, game_);
    online_error_.clear();
    std::string text;
    if (guest_->connect(ip_, static_cast<uint16_t>(port_), nick_, password_, join_spectate_, online_error_) &&
        online_deck_ < static_cast<int>(decks_.size()) &&
        wxtest::read_deck_text(wxtest::data_dir() + "/decks/" + decks_[online_deck_] + ".json", text))
      guest_->send_deck(text);
  }
  ImGui::EndDisabled();
  ImGui::SameLine();
  if (ImGui::Button("메뉴로", ImVec2(140, 0))) {
    leave_online();
    finder_.reset();
    screen_ = Screen::Menu;
  }
  if (guest_ && !guest_->status.empty()) ImGui::TextDisabled("%s", guest_->status.c_str());
  if (!online_error_.empty()) ImGui::TextColored(kBad, "%s", online_error_.c_str());
  ImGui::End();
}

void App::draw_room(ImVec2 size) {
  const bool hosting = host_ && host_->is_open();
  const RoomState& room = hosting ? host_->room() : guest_->room();
  const bool me_duelist = !hosting && !guest_->spectating();
  ImGui::SetNextWindowPos(ImVec2(size.x * 0.5f, size.y * 0.5f), ImGuiCond_Always, ImVec2(0.5f, 0.5f));
  ImGui::SetNextWindowSize(ImVec2(std::min(size.x - 40, 980.0f), std::min(size.y - 40, 640.0f)));
  const std::string title = (room.locked ? "[잠김] " : "") + room.room_name + "###room";
  ImGui::Begin(title.c_str(), nullptr, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoResize);
  ImGui::TextDisabled("%s", (hosting ? host_->status : guest_->status).c_str());
  if (hosting) {
    std::string ips;
    for (const auto& ip : local_ipv4()) ips += (ips.empty() ? "" : ", ") + ip;
    ImGui::TextDisabled("내 IP: %s  포트 %d   (인터넷 너머라면 포트포워딩이나 가상 LAN이 필요하다)", ips.empty() ? "?" : ips.c_str(), port_);
  }

  ImGui::BeginChild("left", ImVec2(ImGui::GetContentRegionAvail().x * 0.55f, -ImGui::GetFrameHeightWithSpacing() * 1.4f));
  // P1: 방장
  ImGui::SeparatorText("P1");
  ImGui::Text("%s%s", room.host_name.c_str(), hosting ? " (나)" : "");
  if (hosting) {
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
  }
  // P2: 게스트
  ImGui::SeparatorText("P2");
  if (room.guest_name.empty()) {
    ImGui::TextDisabled("(비어 있음)");
    if (!hosting && guest_->spectating() && !room.in_duel && ImGui::Button("대전자로")) guest_->to_duelist();
  } else {
    ImGui::Text("%s%s", room.guest_name.c_str(), me_duelist ? " (나)" : "");
    ImGui::SameLine();
    if (room.guest_ready) ImGui::TextColored(kGood, "준비 완료");
    else ImGui::TextColored(kWarn, "준비 안 됨");
    if (hosting && !room.in_duel) {
      ImGui::SameLine();
      if (ImGui::SmallButton("강퇴##guest")) host_->kick_guest();
    }
    if (me_duelist && !room.in_duel) {
      ImGui::TextUnformatted("덱");
      ImGui::SameLine();
      if (deck_combo("##joindeck2", online_deck_)) {
        std::string text;
        if (wxtest::read_deck_text(wxtest::data_dir() + "/decks/" + decks_[online_deck_] + ".json", text)) guest_->send_deck(text);
      }
    }
    if (room.guest_deck_ok || !room.guest_problems.empty()) problems_list(room.guest_problems);
    else ImGui::TextDisabled("덱을 기다리는 중");
    if (me_duelist && !room.in_duel) {
      const bool can_ready = room.guest_deck_ok || (!room.check_decks && !room.guest_problems.empty());
      ImGui::BeginDisabled(!can_ready && !guest_->ready());
      if (ImGui::Button(guest_->ready() ? "준비 취소" : "준비", ImVec2(120, 0))) guest_->set_ready(!guest_->ready());
      ImGui::EndDisabled();
      ImGui::SameLine();
      if (ImGui::Button("관전으로", ImVec2(120, 0))) guest_->to_spectator();
      // 확인용(--join): 덱 검사가 끝나면 바로 준비
      if (dev_auto_start_ && room.guest_deck_ok && !guest_->ready()) {
        guest_->set_ready(true);
        dev_auto_start_ = false;
      }
    }
  }
  // 관전자
  ImGui::SeparatorText(("관전 " + std::to_string(room.spectators.size()) + "명").c_str());
  for (size_t i = 0; i < room.spectators.size(); ++i) {
    ImGui::BulletText("%s", room.spectators[i].c_str());
    if (hosting) {
      ImGui::SameLine();
      ImGui::PushID(static_cast<int>(i));
      if (ImGui::SmallButton("강퇴")) host_->kick_spectator(i);
      ImGui::PopID();
    }
  }
  // 방 설정
  ImGui::SeparatorText("방 설정");
  if (hosting) {
    bool check = room.check_decks;
    if (ImGui::Checkbox("덱 검사(끄면 문제가 있어도 시작)", &check)) host_->set_check_decks(check);
  } else {
    ImGui::TextDisabled("덱 검사: %s", room.check_decks ? "켬" : "끔");
  }
  ImGui::EndChild();

  ImGui::SameLine();
  ImGui::BeginChild("right", ImVec2(0, -ImGui::GetFrameHeightWithSpacing() * 1.4f));
  ImGui::SeparatorText("대화");
  draw_chat(ImGui::GetContentRegionAvail().y - ImGui::GetFrameHeightWithSpacing() - 4);
  ImGui::EndChild();

  // 아래 버튼
  if (hosting) {
    const bool my_ok = my_deck_loaded_ && (!room.check_decks || my_deck_problems_.empty());
    const bool ready = host_->can_start() && my_ok;
    ImGui::BeginDisabled(!ready);
    if (ImGui::Button("대전 시작", ImVec2(160, 0)) || (dev_auto_start_ && ready)) {
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
    if (!host_->can_start()) {
      ImGui::SameLine();
      ImGui::TextDisabled(room.guest_name.empty() ? "P2를 기다리는 중" : "P2가 준비하면 시작할 수 있다");
    }
    ImGui::SameLine(ImGui::GetWindowWidth() - 170);
    if (ImGui::Button("방 닫기", ImVec2(160, 0))) {
      leave_online();
      screen_ = Screen::Menu;
    }
  } else {
    ImGui::TextDisabled(room.in_duel ? "대전 중(관전으로 따라잡는 중)" : "방장이 대전을 시작하기를 기다리는 중");
    ImGui::SameLine(ImGui::GetWindowWidth() - 170);
    if (ImGui::Button("나가기", ImVec2(160, 0))) {
      leave_online();
      screen_ = Screen::Menu;
    }
  }
  if (!online_error_.empty()) ImGui::TextColored(kBad, "%s", online_error_.c_str());
  ImGui::End();
}

}  // namespace wxframe
