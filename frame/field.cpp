// 장 화면. 원근 없는 평면 2D. 아래가 나, 위가 상대(내 쪽 배치를 180도 돌린 것).
// 길이는 세로 카드 폭 cw 단위로 잡고 창 크기에 맞춘다.
//
// 공식 플레이시트 배치를 따른다.
//   내 쪽(가운데 줄에서 아래로)     x: -4.5   -3.0   -1.5    0    1.5    3.0    4.2
//     시그니 줄                        에나   체크   시그니 좌·중앙·우   덱    트래시
//     루리그 줄                         ↓     키     어시·센터·어시      루리그 덱·루리그 트래시
//     라이프 줄                         ↓            라이프 클로스(가로로 겹침)   제외
//     패                         (에나는 가로 카드를 세로로 겹쳐 세 줄에 걸친다)
// 상대 쪽은 x·y를 뒤집으므로 상대 시그니 좌가 내 시그니 우의 정면에 온다(존 레지스트리의 정면 링크와 같다).
#include <imgui.h>

#include <algorithm>
#include <cfloat>
#include <cmath>
#include <string>

#include "view.h"

namespace wxframe {

namespace {

constexpr float kRatio = 88.0f / 63.0f;  // 카드 세로/가로
constexpr float kSlot = 1.4f;            // 장 칸 한 변(cw 단위). 다운한 카드도 들어간다
constexpr float kLife = 0.8f;            // 라이프 줄 높이
constexpr float kGap = 0.08f;
constexpr float kOppHand = 0.55f;        // 상대 패 카드 크기
constexpr float kBar = 36.0f;            // 가운데 줄 높이(px)

const ImU32 kSlotLine = IM_COL32(90, 100, 130, 170);
const ImU32 kSlotFill = IM_COL32(28, 32, 44, 220);
const ImU32 kGateFill = IM_COL32(72, 40, 104, 220);
const ImU32 kPick = IM_COL32(255, 160, 40, 255);
const ImU32 kText = IM_COL32(220, 224, 235, 255);
const ImU32 kFaint = IM_COL32(120, 128, 150, 255);
const ImVec4 kSelectGlow(0.27f, 0.59f, 1.0f, 1.0f);  // 고를 수 있는 카드
const ImVec4 kActGlow(0.30f, 0.90f, 0.45f, 1.0f);    // 행동할 수 있는 카드
const ImVec4 kZoneGlow(1.0f, 0.85f, 0.25f, 1.0f);    // 고를 수 있는 존

// UTF-8 글자 n개까지(줄바꿈에서 끊는다). 잘렸으면 「…」
std::string utf8_prefix(const std::string& s, size_t n) {
  size_t i = 0, count = 0;
  while (i < s.size() && count < n && s[i] != '\n') {
    const unsigned char c = static_cast<unsigned char>(s[i]);
    i += c < 0x80 ? 1 : c < 0xE0 ? 2 : c < 0xF0 ? 3 : 4;
    ++count;
  }
  return i < s.size() ? s.substr(0, i) + "…" : s;
}

// 깜박이는 테두리 색
ImU32 glow(ImVec4 c) {
  c.w = 0.55f + 0.45f * std::sin(static_cast<float>(ImGui::GetTime()) * 5);
  return ImGui::GetColorU32(c);
}

// 왼쪽 위부터 시계 방향 네 점. rot이면 가운데 기준 시계 방향 90도
void quad(ImVec2 c, float w, float h, bool rot, ImVec2 out[4]) {
  const ImVec2 p[4] = {{-w / 2, -h / 2}, {w / 2, -h / 2}, {w / 2, h / 2}, {-w / 2, h / 2}};
  for (int i = 0; i < 4; ++i) out[i] = rot ? ImVec2(c.x - p[i].y, c.y + p[i].x) : ImVec2(c.x + p[i].x, c.y + p[i].y);
}

void text_center(ImDrawList* dl, float size, ImVec2 c, ImU32 col, const std::string& s) {
  ImFont* f = ImGui::GetFont();
  const ImVec2 ts = f->CalcTextSizeA(size, FLT_MAX, 0, s.c_str());
  dl->AddText(f, size, ImVec2(c.x - ts.x / 2, c.y - ts.y / 2), col, s.c_str());
}

// 폭 max_w 안에 들어가게 줄인 글자 크기
float fit_size(float size, const std::string& s, float max_w) {
  const float w = ImGui::GetFont()->CalcTextSizeA(size, FLT_MAX, 0, s.c_str()).x;
  return w > max_w ? size * max_w / w : size;
}

// 둥근 배경 위 글자
void badge(ImDrawList* dl, float size, ImVec2 c, ImU32 bg, const std::string& s) {
  const ImVec2 ts = ImGui::GetFont()->CalcTextSizeA(size, FLT_MAX, 0, s.c_str());
  const float px = size * 0.35f, py = size * 0.1f;
  dl->AddRectFilled(ImVec2(c.x - ts.x / 2 - px, c.y - ts.y / 2 - py), ImVec2(c.x + ts.x / 2 + px, c.y + ts.y / 2 + py), bg,
                    size * 0.4f);
  text_center(dl, size, c, kText, s);
}

void slot_rect(ImDrawList* dl, ImVec2 c, ImVec2 size, ImU32 fill) {
  const ImVec2 a(c.x - size.x / 2, c.y - size.y / 2), b(c.x + size.x / 2, c.y + size.y / 2);
  dl->AddRectFilled(a, b, fill, 6.0f);
  dl->AddRect(a, b, kSlotLine, 6.0f, 0, 1.5f);
}

}  // namespace

void App::toggle_pick(uint32_t handle) {
  auto it = std::find(picks_.begin(), picks_.end(), handle);
  if (it != picks_.end())
    picks_.erase(it);
  else
    picks_.push_back(handle);
}

std::vector<ReqOption> App::card_actions(uint32_t handle) const {
  std::vector<ReqOption> out;
  const auto& r = game_.request();
  if (!r || r->player != viewer_ || r->type != WX_REQ_SELECT_ACTION || !handle) return out;
  for (const auto& o : r->options)
    if (o.handle == handle) out.push_back(o);
  return out;
}

int App::zone_choice(int zone) const {
  const auto& r = game_.request();
  if (!r || r->player != viewer_ || r->type != WX_REQ_SELECT_OPTION || r->hint != WX_HINT_ZONE) return -1;
  for (const auto& o : r->options)
    if (static_cast<int>(o.value) == zone) return zone;
  return -1;
}

bool App::shown_on_field(uint32_t handle) {
  const wx_card_info c = game_.card(viewer_, handle);
  if (c.host || c.zone >= game_.zones().size()) return false;  // 아래 카드는 장에서 안 보인다
  const std::string& n = game_.zones()[c.zone].name;
  return n == "hand" || n == "ena" || n == "life_cloth" || n == "check" || n == "key" || n.rfind("signi", 0) == 0 ||
         n == "lrig_center" || n.rfind("lrig_assist", 0) == 0;
}

void App::draw_field(ImVec2 pos, ImVec2 size) {
  ImGui::SetNextWindowPos(pos);
  ImGui::SetNextWindowSize(size);
  ImGui::PushStyleColor(ImGuiCol_WindowBg, IM_COL32(16, 19, 28, 255));
  // 배경 창: 눌러도 앞으로 올라오지 않는다(요청·더미 창이 뒤에 숨지 않게)
  ImGui::Begin("장", nullptr,
               ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoCollapse |
                   ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoScrollWithMouse |
                   ImGuiWindowFlags_NoBringToFrontOnFocus);
  ImGui::PopStyleColor();
  // 배경 그림(textures/bg): 창을 덮도록 잘라 붙이고 어둡게 덮는다
  if (const Texture& bg = tex_.file("bg"); bg.id) {
    const float sx = size.x / bg.w, sy = size.y / bg.h, s = std::max(sx, sy);
    const float u = (1 - sx / s) / 2, v = (1 - sy / s) / 2;
    ImDrawList* dl = ImGui::GetWindowDrawList();
    dl->AddImage(bg.id, pos, ImVec2(pos.x + size.x, pos.y + size.y), ImVec2(u, v), ImVec2(1 - u, 1 - v));
    dl->AddRectFilled(pos, ImVec2(pos.x + size.x, pos.y + size.y), IM_COL32(10, 12, 20, 195));
  }
  const ImVec2 a = ImGui::GetWindowContentRegionMin(), b = ImGui::GetWindowContentRegionMax();
  const ImVec2 o(pos.x + a.x, pos.y + a.y);
  const float W = b.x - a.x, H = b.y - a.y;
  // 높이: 상대 패 + 양쪽 (시그니·루리그·라이프) + 내 패 + 가운데 줄. 폭: 내 쪽 -5.1 ~ 4.7, 상대 쪽은 거울이라 ±5.1
  const float side = 4 * kGap + 2 * kSlot + kLife;
  const float cw = std::min(W / 10.4f, (H - kBar) / (2 * side + kOppHand * kRatio + kRatio));
  const float top = (side + kOppHand * kRatio) * cw;
  const float cx = o.x + W / 2;
  const float cy = o.y + (H - (2 * side + kOppHand * kRatio + kRatio) * cw - kBar) / 2 + top + kBar / 2;

  field_center_ = ImVec2(cx, cy);
  draw_side(1 - viewer_, ImVec2(cx, cy - kBar / 2), -1, cw);
  draw_side(viewer_, ImVec2(cx, cy + kBar / 2), 1, cw);
  draw_middle_bar(ImVec2(o.x, cy - kBar / 2), ImVec2(o.x + W, cy + kBar / 2));
  ImGui::End();
  draw_zone_window();
  draw_action_menu();
}

void App::draw_middle_bar(ImVec2 a, ImVec2 b) {
  ImDrawList* dl = ImGui::GetWindowDrawList();
  dl->AddRectFilled(a, b, IM_COL32(34, 40, 60, 255));
  const wx_game_info& g = game_.model(viewer_).game();
  char buf[128];
  std::snprintf(buf, sizeof buf, "%u턴  P%d", g.turn_count, g.turn_player + 1);
  const float fs = ImGui::GetFontSize();
  dl->AddText(ImVec2(a.x + 12, (a.y + b.y - fs) / 2),
              g.turn_player == viewer_ ? IM_COL32(120, 200, 255, 255) : IM_COL32(255, 140, 120, 255), buf);
  // 페이즈 줄: 지금 페이즈를 밝게
  static const std::pair<uint32_t, const char*> kPhases[] = {
      {WX_PHASE_UP, "업"},     {WX_PHASE_DRAW, "드로"},   {WX_PHASE_ENA, "에나"}, {WX_PHASE_GROW, "그로우"},
      {WX_PHASE_MAIN, "메인"}, {WX_PHASE_ATTACK, "어택"}, {WX_PHASE_END, "엔드"}};
  float px = a.x + 12 + ImGui::CalcTextSize(buf).x + 20;
  const bool compact = b.x - a.x < 1000;  // 좁으면 지금 페이즈만
  for (const auto& [bit, name] : kPhases) {
    const bool now = g.phase == bit;
    if (compact && !now) continue;
    const ImVec2 p0(px, a.y + 6), p1(px + ImGui::CalcTextSize(name).x + 16, b.y - 6);
    if (now) dl->AddRectFilled(p0, p1, IM_COL32(60, 120, 220, 255), 4.0f);
    dl->AddText(ImVec2(px + 8, (a.y + b.y - fs) / 2), now ? kText : kFaint, name);
    px = p1.x + 4;
  }
  if (game_.ended()) {
    std::snprintf(buf, sizeof buf, "승리: P%d", game_.winner() + 1);
    text_center(dl, fs * 1.2f, ImVec2((a.x + b.x) / 2, (a.y + b.y) / 2), IM_COL32(255, 215, 60, 255), buf);
  }
  // 오른쪽 버튼
  const float bh = b.y - a.y - 8;
  float x = b.x - 8;
  auto button = [&](const char* label) {
    const float w = ImGui::CalcTextSize(label).x + 24;
    x -= w;
    ImGui::SetCursorScreenPos(ImVec2(x, a.y + 4));
    x -= 6;
    return ImGui::Button(label, ImVec2(w, bh));
  };
  // 온라인: 방장은 방으로 돌아가고, 게스트는 나간다
  if (host_ && host_->is_open()) {
    if (button("방으로")) {
      host_->back_to_room();
      screen_ = Screen::Host;
    }
  } else if (game_.remote()) {
    if (button("나가기")) {
      leave_online();
      screen_ = Screen::Menu;
    }
  } else if (button("새 대전")) {
    game_.reset();  // 혼자 하기 설정 화면으로
    screen_ = Screen::Solo;
    open_zone_ = -1;
  }
  if (game_.practice() && button("되돌리기")) {
    game_.undo();
    picks_.clear();
  }
  // 페이즈 줄과 오른쪽 버튼 사이: 지금 할 일
  draw_bar_request(ImVec2(px + 16, a.y), ImVec2(x - 16, b.y));
}

// 가운데 줄의 요청 칸: 안내, 확정·지우기·취소, 카드 없는 행동(페이즈 끝내기·리무브)
void App::draw_bar_request(ImVec2 a, ImVec2 b) {
  const auto& req = game_.request();
  if (!req || b.x <= a.x) return;
  const Request r = *req;  // 응답하면 요청이 바뀌므로 복사해 둔다
  const float bh = b.y - a.y - 8;
  ImGui::SetCursorScreenPos(ImVec2(a.x, a.y + 4));
  ImGui::PushClipRect(a, b, true);
  ImGui::AlignTextToFramePadding();
  if (r.player != viewer_) {
    ImGui::TextColored(ImVec4(1.0f, 0.6f, 0.5f, 1), "P%d 고르는 중: %s", r.player + 1, hint_name(r.hint));
    ImGui::PopClipRect();
    return;
  }
  auto button = [&](const char* label, bool enabled = true) {
    ImGui::SameLine();
    ImGui::BeginDisabled(!enabled);
    const bool pressed = ImGui::Button(label, ImVec2(0, bh));
    ImGui::EndDisabled();
    return pressed;
  };
  if (place_handle_) {
    ImGui::TextColored(ImVec4(1.0f, 0.85f, 0.25f, 1), "%s: 낼 시그니 존을 누른다",
                       game_.card_label(viewer_, place_handle_).c_str());
    if (button("배치 취소")) place_handle_ = 0;
    ImGui::PopClipRect();
    return;
  }
  ImGui::TextColored(ImVec4(0.55f, 0.8f, 1.0f, 1), "%s", hint_name(r.hint));
  if (r.source) {
    ImGui::SameLine();
    source_label(r.source);
  }
  if (r.type == WX_REQ_SELECT_ACTION) {
    const wx_game_info& g = game_.model(viewer_).game();
    for (const auto& o : r.options) {
      if (o.handle) continue;
      std::string label = o.kind == WX_ACT_END ? std::string(phase_name(g.phase)) + " 끝내기" : action_label(o);
      label += "##a" + std::to_string(o.value);
      if (button(label.c_str())) {
        picks_.clear();
        game_.respond({o.value});
        ImGui::PopClipRect();
        return;
      }
    }
    // 예전 방식 목록(빛나는 카드를 못 찾을 때)
    if (button("목록")) ImGui::OpenPopup("actlist");
    if (ImGui::BeginPopup("actlist")) {
      for (const auto& o : r.options) {
        const std::string label = action_label(o) + "##l" + std::to_string(o.value);
        if (ImGui::Selectable(label.c_str())) {
          picks_.clear();
          game_.respond({o.value});
          break;
        }
      }
      ImGui::EndPopup();
    }
  } else if (r.type == WX_REQ_SELECT_CARDS) {
    ImGui::SameLine();
    if (r.min == r.max)
      ImGui::Text("%zu/%u", picks_.size(), r.max);
    else
      ImGui::Text("%zu (%u~%u)", picks_.size(), r.min, r.max);
    if (button(picks_.empty() && r.min == 0 ? "고르지 않고 진행" : "확정", picks_ok())) confirm_picks();
    if (!picks_.empty() && button("지우기")) picks_.clear();
  }
  if (r.cancelable && button("취소")) {
    picks_.clear();
    game_.cancel();
  }
  const std::string& retry = game_.retry(viewer_);
  if (!retry.empty()) {
    ImGui::SameLine();
    ImGui::TextColored(ImVec4(1, 0.5f, 0.4f, 1), "다시: %s", retry.c_str());
  }
  ImGui::PopClipRect();
}

// mid: 가운데 줄의 이쪽 가장자리, s: 아래로 펼치면 1(나), 위로 펼치면 -1(상대)
void App::draw_side(int p, ImVec2 mid, float s, float cw) {
  ImGui::PushID(p);
  ImDrawList* dl = ImGui::GetWindowDrawList();
  const float S = kSlot * cw, g = kGap * cw, L = kLife * cw;
  auto at = [&](float x, float y) { return ImVec2(mid.x + s * x * cw, mid.y + s * y); };
  const float y_signi = g + S / 2, y_lrig = g + S + g + S / 2, y_life = g + S + g + S + g + L / 2;
  const float hand_w = p == viewer_ ? cw : kOppHand * cw;
  const float y_hand = g + S + g + S + g + L + g + hand_w * kRatio / 2;
  auto cards_of = [&](const char* n) { return game_.zone_cards(viewer_, game_.zone(static_cast<uint8_t>(p), n)); };

  // 에나: 왼쪽 끝 세로 줄. 가로 카드를 겹친다
  CardOpt eo;
  eo.rot = true;
  eo.dir = ImVec2(0, s);
  eo.from_start = true;  // 가운데 줄 쪽부터 쌓는다
  const auto ena = cards_of("ena");
  const float ena_span = 2 * g + 2 * S + L;
  const ImVec2 ena_c = at(-4.5f, g + ena_span / 2);
  slot_rect(dl, ena_c, ImVec2(0.8f * cw * kRatio + 6, ena_span), kSlotFill);
  if (ena.empty()) text_center(dl, ImGui::GetFontSize() * 0.8f, ena_c, kFaint, "에나");
  card_row(ena, ena_c, ena_span - 6, 0.8f * cw, eo);
  if (!ena.empty())
    badge(dl, ImGui::GetFontSize() * 0.8f, at(-4.5f, g + ImGui::GetFontSize() * 0.6f), IM_COL32(0, 0, 0, 200),
          "에나 " + std::to_string(ena.size()));

  // 시그니 줄
  pile(p, "check", at(-3.0f, y_signi), cw, false);
  field_slot(p, "signi_left", at(-1.5f, y_signi), cw);
  field_slot(p, "signi_center", at(0, y_signi), cw);
  field_slot(p, "signi_right", at(1.5f, y_signi), cw);
  pile(p, "main_deck", at(3.0f, y_signi), cw, false);
  pile(p, "trash", at(4.2f, y_signi), cw, false);

  // 루리그 줄
  field_slot(p, "key", at(-3.0f, y_lrig), cw);
  field_slot(p, "lrig_assist_left", at(-1.5f, y_lrig), cw);
  field_slot(p, "lrig_center", at(0, y_lrig), cw);
  field_slot(p, "lrig_assist_right", at(1.5f, y_lrig), cw);
  pile(p, "lrig_deck", at(3.0f, y_lrig), cw, true);
  pile(p, "lrig_trash", at(4.2f, y_lrig), cw, false);

  // 라이프 클로스: 가로 카드를 옆으로 겹친다
  const auto life = cards_of("life_cloth");
  CardOpt lo;
  lo.rot = true;
  lo.dir = ImVec2(s, 0);
  card_row(life, at(0, y_life), 4.4f * cw, L * 0.92f, lo);
  text_center(dl, ImGui::GetFontSize(), at(-3.0f, y_life), kFaint, "라이프 " + std::to_string(life.size()));
  zone_button(p, "exclude", at(3.6f, y_life));

  // 패
  CardOpt ho;
  ho.dir = ImVec2(s, 0);
  card_row(cards_of("hand"), at(0, y_hand), 6.6f * cw, hand_w, ho);

  // 플레이어 정보: 패 줄 왼쪽
  const wx_player_info& info = game_.model(viewer_).player(p);
  const ImVec2 c = at(-4.2f, y_hand);
  const float fs = ImGui::GetFontSize();
  text_center(dl, fs, ImVec2(c.x, c.y - fs * 0.7f), p == viewer_ ? IM_COL32(120, 200, 255, 255) : IM_COL32(255, 140, 120, 255),
              "P" + std::to_string(p + 1) + (p == viewer_ ? " (나)" : " (상대)"));
  text_center(dl, fs * 0.85f, ImVec2(c.x, c.y + fs * 0.5f), kFaint,
              "코인 " + std::to_string(info.coins) + "  상한 " + std::to_string(info.hand_limit));
  ImGui::PopID();
}

// 시그니·루리그·키 칸: 맨 위 카드 한 장
void App::field_slot(int p, const char* name, ImVec2 c, float cw) {
  ImDrawList* dl = ImGui::GetWindowDrawList();
  const int z = game_.zone(static_cast<uint8_t>(p), name);
  const bool gate = z >= 0 && game_.model(viewer_).gate(static_cast<uint16_t>(z));
  const float S = kSlot * cw;
  slot_rect(dl, c, ImVec2(S, S), gate ? kGateFill : kSlotFill);
  const auto cards = game_.zone_cards(viewer_, z);
  const float fs = ImGui::GetFontSize() * 0.8f;
  if (cards.empty()) text_center(dl, fit_size(fs, zone_label(name), S * 0.9f), c, kFaint, zone_label(name));
  // 존 선택 요청: 칸 전체를 누른다. 겹치면 먼저 넣은 항목이 눌리므로 카드보다 먼저 넣는다
  // 존 고르기 요청이면 그 응답 값, 배치 중이면 이 존에 내는 행동 번호
  int choice = zone_choice(z);
  if (choice < 0 && place_handle_)
    for (const auto& o : card_actions(place_handle_))
      if (o.kind == WX_ACT_PLAY_SIGNI && o.zone == z) choice = static_cast<int>(o.value);
  bool chosen = false;
  if (choice >= 0) {
    ImGui::SetCursorScreenPos(ImVec2(c.x - S / 2, c.y - S / 2));
    ImGui::PushID(name);
    chosen = ImGui::InvisibleButton("zone", ImVec2(S, S));
    ImGui::PopID();
  }
  CardOpt opt;
  opt.stats = std::string(name).rfind("signi", 0) == 0;
  if (!cards.empty()) card_widget(cards.back(), c, cw, opt);
  if (gate) badge(dl, fs, ImVec2(c.x, c.y - S / 2 + fs * 0.6f), IM_COL32(120, 60, 170, 230), "ゲート");
  if (choice >= 0)
    dl->AddRect(ImVec2(c.x - S / 2, c.y - S / 2), ImVec2(c.x + S / 2, c.y + S / 2), glow(kZoneGlow), 6.0f, 0, 3.0f);
  if (chosen) {
    place_handle_ = 0;
    game_.respond({static_cast<uint32_t>(choice)});
  }
}

// 덱·트래시 같은 더미: 맨 위 카드와 장 수. 누르면 펼쳐 본다(비공개 더미 제외)
void App::pile(int p, const char* name, ImVec2 c, float cw, bool lrig_back) {
  ImDrawList* dl = ImGui::GetWindowDrawList();
  const int z = game_.zone(static_cast<uint8_t>(p), name);
  const auto cards = game_.zone_cards(viewer_, z);
  const float h = cw * kRatio;
  slot_rect(dl, c, ImVec2(cw, h), kSlotFill);
  const float fs = ImGui::GetFontSize() * 0.8f;
  wx_card_info top{};
  if (!cards.empty()) {
    top = game_.card(viewer_, cards.back());
    if (lrig_back) top.known = 0;  // 루리그 덱은 주인이 알아도 더미는 뒷면으로(펼치면 보인다)
    draw_card_face(top, c, cw, false, lrig_back);
  } else {
    text_center(dl, fit_size(fs, zone_label(name), cw * 0.9f), c, kFaint, zone_label(name));
  }
  const bool can = std::any_of(cards.begin(), cards.end(), [&](uint32_t hd) { return selectable(hd); });
  const bool act = std::any_of(cards.begin(), cards.end(), [&](uint32_t hd) { return !card_actions(hd).empty(); });
  if (can || act)
    dl->AddRect(ImVec2(c.x - cw / 2, c.y - h / 2), ImVec2(c.x + cw / 2, c.y + h / 2), glow(can ? kSelectGlow : kActGlow), 6.0f,
                0, 3.0f);
  if (!cards.empty()) {
    // 이름까지 넣으면 카드보다 넓을 때는 장 수만
    std::string label = zone_label(name) + " " + std::to_string(cards.size());
    if (ImGui::GetFont()->CalcTextSizeA(fs, FLT_MAX, 0, label.c_str()).x > cw * 0.85f) label = std::to_string(cards.size());
    badge(dl, fs, ImVec2(c.x, c.y + h / 2 - fs * 0.7f), IM_COL32(0, 0, 0, 190), label);
  }
  ImGui::SetCursorScreenPos(ImVec2(c.x - cw / 2, c.y - h / 2));
  ImGui::PushID(name);
  // 아는 카드가 하나라도 있으면 펼쳐 볼 수 있다(덱·라이프는 모두 뒷면이라 안 열린다)
  const bool any_known = std::any_of(cards.begin(), cards.end(), [&](uint32_t hd) { return game_.card(viewer_, hd).known; });
  if (ImGui::InvisibleButton("pile", ImVec2(cw, h)) && (any_known || can || act)) {
    open_zone_ = z;
    zone_focus_ = true;
  }
  if (ImGui::IsItemHovered() && top.known) {
    preview_cid_ = top.cid;
    preview_handle_ = top.handle;
  }
  ImGui::PopID();
}

// 카드 여러 장을 opt.dir 방향으로 늘어놓는다. span을 넘으면 겹친다
void App::card_row(const std::vector<uint32_t>& cards, ImVec2 c, float span, float w, const CardOpt& opt) {
  if (cards.empty()) return;
  const bool across = opt.dir.x != 0;  // 가로로 늘어놓는가
  const ImVec2 box = opt.rot ? ImVec2(w * kRatio, w) : ImVec2(w, w * kRatio);  // 화면에서 차지하는 크기
  const float len = across ? box.x : box.y;
  const size_t n = cards.size();
  float step = len * 1.06f;
  if (n > 1) step = std::min(step, (span - len) / static_cast<float>(n - 1));
  const float first = opt.from_start ? -span / 2 + len / 2 : -(len + step * static_cast<float>(n - 1)) / 2 + len / 2;
  for (size_t i = 0; i < n; ++i) {
    CardOpt o = opt;
    if (i + 1 < n && step < len) o.hit = step;
    const float d = first + step * static_cast<float>(i);
    card_widget(cards[i], ImVec2(c.x + opt.dir.x * d, c.y + opt.dir.y * d), w, o);
  }
}

// 작은 버튼 하나로 보이는 존(제외). 누르면 펼쳐 본다
void App::zone_button(int p, const char* name, ImVec2 c) {
  const int z = game_.zone(static_cast<uint8_t>(p), name);
  const auto cards = game_.zone_cards(viewer_, z);
  const bool can = std::any_of(cards.begin(), cards.end(), [&](uint32_t hd) { return selectable(hd); });
  const std::string label = zone_label(name) + " " + std::to_string(cards.size()) + "##" + name;
  const ImVec2 size(ImGui::CalcTextSize(label.c_str(), nullptr, true).x + 20, ImGui::GetFrameHeight());
  ImGui::SetCursorScreenPos(ImVec2(c.x - size.x / 2, c.y - size.y / 2));
  if (can) ImGui::PushStyleColor(ImGuiCol_Button, IM_COL32(50, 110, 200, 255));
  if (ImGui::Button(label.c_str(), size) && !cards.empty()) {
    open_zone_ = z;
    zone_focus_ = true;
  }
  if (can) ImGui::PopStyleColor();
}

void App::card_widget(uint32_t handle, ImVec2 c, float w, const CardOpt& opt) {
  ImDrawList* dl = ImGui::GetWindowDrawList();
  const wx_card_info info = game_.card(viewer_, handle);
  const bool rot = opt.rot || (info.flags & 1);
  const float h = w * kRatio;
  draw_card_face(info, c, w, rot, opt.lrig_back);

  const float fs = ImGui::GetFontSize() * 0.8f;
  const ImVec2 box = rot ? ImVec2(h, w) : ImVec2(w, h);  // 화면상 사각형
  if (opt.stats && info.known && (info.type & 0x2))
    badge(dl, fs * 1.1f, ImVec2(c.x, c.y + box.y / 2 - fs * 0.8f), IM_COL32(0, 0, 0, 200), std::to_string(info.power));
  if (info.n_under)
    badge(dl, fs, ImVec2(c.x + box.x / 2 - fs, c.y - box.y / 2 + fs * 0.8f), IM_COL32(60, 60, 80, 230),
          "+" + std::to_string(info.n_under));

  const bool can = selectable(handle);
  const bool act = !card_actions(handle).empty();
  const auto it = std::find(picks_.begin(), picks_.end(), handle);
  const bool picked = it != picks_.end();
  if (picked || can || act) {
    ImVec2 q[4];
    quad(c, w, h, rot, q);
    const ImU32 col = picked || handle == place_handle_ ? kPick : glow(can ? kSelectGlow : kActGlow);
    dl->AddPolyline(q, 4, col, ImDrawFlags_Closed, 3.0f);
    if (picked)
      badge(dl, fs * 1.2f, c, IM_COL32(200, 110, 20, 240), std::to_string(it - picks_.begin() + 1));
  }

  // 겹쳐 놓았으면 다음 카드에 가려지지 않은 쪽(dir 반대쪽)만 누를 수 있다
  ImVec2 hit_min(c.x - box.x / 2, c.y - box.y / 2), hit_size = box;
  if (opt.hit > 0) {
    if (opt.dir.x != 0) {
      hit_size.x = opt.hit;
      if (opt.dir.x < 0) hit_min.x = c.x + box.x / 2 - opt.hit;
    } else {
      hit_size.y = opt.hit;
      if (opt.dir.y < 0) hit_min.y = c.y + box.y / 2 - opt.hit;
    }
  }
  ImGui::SetCursorScreenPos(hit_min);
  ImGui::PushID(static_cast<int>(handle));
  if (ImGui::InvisibleButton("card", hit_size)) {
    if (can) {
      toggle_pick(handle);
    } else if (act) {
      place_handle_ = 0;
      menu_handle_ = handle;
      menu_pos_ = ImGui::GetIO().MousePos;
      menu_frame_ = ImGui::GetFrameCount();
    }
  }
  if (ImGui::IsItemHovered() && info.known) {
    preview_cid_ = info.cid;
    preview_handle_ = handle;
  }
  ImGui::PopID();
}

void App::draw_card_face(const wx_card_info& c, ImVec2 ctr, float w, bool rot, bool lrig_back) {
  ImDrawList* dl = ImGui::GetWindowDrawList();
  const float h = w * kRatio;
  ImVec2 q[4];
  quad(ctr, w, h, rot, q);
  const Texture& t = c.known ? tex_.card(c.cid) : Texture{};
  if (t.id) {
    dl->AddImageQuad(t.id, q[0], q[1], q[2], q[3]);
  } else if (c.known) {
    // 그림 없는 카드: 이름만
    dl->AddQuadFilled(q[0], q[1], q[2], q[3], IM_COL32(60, 66, 84, 255));
    if (!rot) {
      const std::string name = game_.db().text_of(c.cid).name;
      const float fs = ImGui::GetFontSize() * 0.75f;
      dl->AddText(ImGui::GetFont(), fs, ImVec2(ctr.x - w / 2 + 4, ctr.y - h / 2 + 4), kText, name.c_str(), nullptr, w - 8);
    }
  } else if (const Texture& back = tex_.file(lrig_back ? "cover_lrig" : "cover"); back.id) {
    dl->AddImageQuad(back.id, q[0], q[1], q[2], q[3]);
  } else {
    // 뒷면 그림이 없으면 직접 그린다: 메인 덱은 남색, 루리그 덱은 자주색
    dl->AddQuadFilled(q[0], q[1], q[2], q[3], lrig_back ? IM_COL32(70, 30, 80, 255) : IM_COL32(22, 30, 64, 255));
    ImVec2 in[4];
    quad(ctr, w * 0.78f, h * 0.84f, rot, in);
    dl->AddPolyline(in, 4, lrig_back ? IM_COL32(200, 140, 220, 160) : IM_COL32(130, 160, 230, 160), ImDrawFlags_Closed, 1.5f);
    dl->AddCircle(ctr, w * 0.22f, lrig_back ? IM_COL32(200, 140, 220, 200) : IM_COL32(130, 160, 230, 200), 0, 2.0f);
  }
  if (c.flags & 2) dl->AddQuadFilled(q[0], q[1], q[2], q[3], IM_COL32(80, 170, 255, 90));  // 동결
  dl->AddPolyline(q, 4, IM_COL32(0, 0, 0, 200), ImDrawFlags_Closed, 1.0f);
}

// 더미를 펼쳐 보는 창
void App::draw_zone_window() {
  if (open_zone_ < 0 || open_zone_ >= static_cast<int>(game_.zones().size())) return;
  const ZoneMeta& zm = game_.zones()[open_zone_];
  bool open = true;
  const ImVec2 ds = ImGui::GetIO().DisplaySize;
  ImGui::SetNextWindowSize(ImVec2(ds.x * 0.45f, ds.y * 0.45f), ImGuiCond_Appearing);
  ImGui::SetNextWindowPos(ImVec2(ds.x * 0.5f, ds.y * 0.5f), ImGuiCond_Appearing, ImVec2(0.5f, 0.5f));
  if (zone_focus_) ImGui::SetNextWindowFocus();  // 이미 열려 있어도 다시 누르면 맨 앞으로
  zone_focus_ = false;
  const std::string title = "P" + std::to_string(zm.owner + 1) + " " + zone_label(zm.name) + "###zone";
  if (ImGui::Begin(title.c_str(), &open, ImGuiWindowFlags_NoCollapse)) {
    const auto all = game_.zone_cards(viewer_, open_zone_);
    draw_thumbs(std::vector<uint32_t>(all.rbegin(), all.rend()), 90.0f);  // 위(마지막) 카드부터
    if (all.empty()) ImGui::TextDisabled("(비어 있음)");
  }
  ImGui::End();
  if (!open) open_zone_ = -1;
}

// 카드 그림을 창 폭에 맞춰 줄지어 놓는다. 누르면 장의 카드와 똑같이 동작한다
void App::draw_thumbs(const std::vector<uint32_t>& cards, float w) {
  const float h = w * kRatio, pad = 8.0f;
  const int per_row = std::max(1, static_cast<int>((ImGui::GetContentRegionAvail().x + pad) / (w + pad)));
  const ImVec2 o = ImGui::GetCursorScreenPos();
  for (size_t i = 0; i < cards.size(); ++i) {
    const int col = static_cast<int>(i) % per_row, row = static_cast<int>(i) / per_row;
    card_widget(cards[i], ImVec2(o.x + col * (w + pad) + w / 2, o.y + row * (h + pad) + h / 2), w, CardOpt{});
  }
  const int rows = (static_cast<int>(cards.size()) + per_row - 1) / per_row;
  ImGui::SetCursorScreenPos(o);
  ImGui::Dummy(ImVec2(per_row * (w + pad), std::max(1, rows) * (h + pad)));
}

bool App::option_card(uint32_t handle, float w) {
  const wx_card_info info = game_.card(viewer_, handle);
  const float h = w * kRatio;
  const ImVec2 o = ImGui::GetCursorScreenPos();
  ImGui::PushID(static_cast<int>(handle));
  const bool pressed = ImGui::InvisibleButton("opt", ImVec2(w, h));
  const bool hovered = ImGui::IsItemHovered();
  ImGui::PopID();
  const ImVec2 c(o.x + w / 2, o.y + h / 2);
  draw_card_face(info, c, w, false, false);
  if (hovered) {
    ImGui::GetWindowDrawList()->AddRect(o, ImVec2(o.x + w, o.y + h), kPick, 6.0f, 0, 3.0f);
    if (info.known) {
      preview_cid_ = info.cid;
      preview_handle_ = handle;
    }
  }
  return pressed;
}

void App::desc_text(uint32_t desc, float width) {
  const std::string t = desc ? game_.db().desc_text(desc) : std::string();
  if (t.empty()) return;
  ImGui::PushTextWrapPos(ImGui::GetCursorPosX() + width);
  ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(200, 205, 220, 255));
  ImGui::TextUnformatted(t.c_str());
  ImGui::PopStyleColor();
  ImGui::PopTextWrapPos();
}

void App::source_label(uint32_t handle) {
  const wx_card_info info = game_.card(viewer_, handle);
  ImGui::TextColored(ImVec4(0.95f, 0.8f, 0.45f, 1), "「%s」", game_.card_label(viewer_, handle).c_str());
  if (ImGui::IsItemHovered() && info.known) {
    preview_cid_ = info.cid;
    preview_handle_ = handle;
  }
}

// 카드를 눌렀을 때 뜨는 행동 메뉴
void App::draw_action_menu() {
  if (!menu_handle_) return;
  const auto acts = card_actions(menu_handle_);
  if (acts.empty()) {
    menu_handle_ = 0;
    return;
  }
  ImGui::SetNextWindowPos(menu_pos_);
  ImGui::SetNextWindowFocus();
  ImGui::Begin("##act", nullptr,
               ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoMove |
                   ImGuiWindowFlags_NoSavedSettings);
  ImGui::TextDisabled("%s", game_.card_label(viewer_, menu_handle_).c_str());
  ImGui::Separator();
  // 시그니 내기는 존마다 행동이 따로 오지만 「배치」 하나로 묶고, 존은 장에서 누른다
  bool placed_item = false;
  int ability_no = 0;
  for (const auto& o : acts) {
    std::string label;
    switch (o.kind) {
      case WX_ACT_PLAY_SIGNI:
        if (placed_item) continue;
        placed_item = true;
        if (ImGui::Selectable("배치")) {
          place_handle_ = menu_handle_;
          menu_handle_ = 0;
        }
        continue;
      case WX_ACT_USE: label = "사용"; break;
      case WX_ACT_ABILITY: {
        ++ability_no;
        const std::string d = o.desc ? game_.db().desc_text(o.desc) : std::string();
        label = d.empty() ? "【起】 " + std::to_string(ability_no) : utf8_prefix(d, 28);
        break;
      }
      case WX_ACT_GROW: label = "그로우"; break;
      case WX_ACT_KEY: label = "키 내기"; break;
      default: label = action_label(o); break;
    }
    label += "##" + std::to_string(o.value);
    if (menu_handle_ && ImGui::Selectable(label.c_str())) {
      menu_handle_ = 0;
      picks_.clear();
      game_.respond({o.value});
      break;
    }
  }
  // 항목을 누르는 순간 그 항목이 활성이 되어 기본 판정은 「안 올라가 있음」이 된다. 그래서 막혀 있어도 센다
  const bool hovered =
      ImGui::IsWindowHovered(ImGuiHoveredFlags_ChildWindows | ImGuiHoveredFlags_AllowWhenBlockedByActiveItem);
  ImGui::End();
  // 바깥을 누르면 닫는다(메뉴를 연 클릭은 빼고)
  if (menu_handle_ && !hovered && ImGui::IsMouseClicked(0) && ImGui::GetFrameCount() != menu_frame_) menu_handle_ = 0;
}

}  // namespace wxframe
