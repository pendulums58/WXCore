// 덱 편집 화면. CyanPro(EDOPro) 덱 에디터 구성을 위크로스에 맞췄다.
//   왼쪽: 카드 정보(대전 화면과 같은 패널)
//   가운데: 위 덱 관리줄, 루리그 덱·메인 덱 그림, 아래 검증 결과
//   오른쪽: 검색 조건과 결과 목록
// 조작: 결과에서 우클릭·더블클릭 = 넣기, 휠클릭 = 판본 골라 넣기, 덱에서 우클릭 = 빼기, 레벨 0 루리그 클릭 = 시작 루리그 지정
#include <imgui.h>

#include <algorithm>
#include <cfloat>
#include <cstring>
#include <filesystem>
#include <map>
#include <set>

#include "deck_check.h"
#include "view.h"

namespace wxframe {

namespace {

constexpr float kRatio = 88.0f / 63.0f;

const char* const kFormats[] = {"diva", "key", "allstar"};
const char* const kFormatLabels[] = {"디바 셀렉션", "키 셀렉션", "올스타"};

struct TypeFilter {
  const char* label;
  uint32_t bits;  // 0 = 전부
};
const TypeFilter kTypeFilters[] = {
    {"전부", 0},
    {"루리그", wx::TYPE_LRIG},
    {"어시스트 루리그", wx::TYPE_ASSIST_LRIG},
    {"아츠", wx::TYPE_ARTS},
    {"피스", wx::TYPE_PIECE},
    {"키", wx::TYPE_KEY},
    {"레조나", wx::TYPE_RESONA},
    {"시그니", wx::TYPE_SIGNI},
    {"스펠", wx::TYPE_SPELL},
};

const struct {
  uint8_t bit;
  const char* label;
  ImVec4 col;
} kColors[] = {
    {wx::COLOR_WHITE, "백", {0.92f, 0.92f, 0.85f, 1}}, {wx::COLOR_RED, "적", {0.95f, 0.35f, 0.35f, 1}},
    {wx::COLOR_BLUE, "청", {0.35f, 0.6f, 1.0f, 1}},    {wx::COLOR_GREEN, "녹", {0.35f, 0.85f, 0.45f, 1}},
    {wx::COLOR_BLACK, "흑", {0.7f, 0.5f, 0.85f, 1}},
};

// 루리그 덱에 들어가는 종류(용어집: ルリグデッキ 「ルリグ・アーツ・レゾナ・キー」, ピース)
bool lrig_side(uint32_t type) {
  return type & (wx::TYPE_LRIG | wx::TYPE_ASSIST_LRIG | wx::TYPE_ARTS | wx::TYPE_PIECE | wx::TYPE_KEY | wx::TYPE_RESONA |
                 wx::TYPE_RELAY);
}

std::string type_label(uint32_t type) {
  for (const auto& t : kTypeFilters)
    if (t.bits && (type & t.bits)) return t.label;
  return "?";
}

std::string color_label(uint8_t color) {
  std::string s;
  for (const auto& c : kColors)
    if (color & c.bit) s += c.label;
  return s.empty() ? "무" : s;
}

int format_index(const std::string& f) {
  for (int i = 0; i < 3; ++i)
    if (f == kFormats[i]) return i;
  return 2;
}

// 정렬 순서: 루리그 → 어시스트 → 피스 → 아츠 → 키 → 레조나 / 시그니 → 스펠, 그다음 레벨·cid
int type_rank(uint32_t type) {
  const uint32_t order[] = {wx::TYPE_LRIG,  wx::TYPE_ASSIST_LRIG, wx::TYPE_PIECE, wx::TYPE_ARTS,
                            wx::TYPE_KEY,   wx::TYPE_RESONA,       wx::TYPE_SIGNI, wx::TYPE_SPELL};
  for (int i = 0; i < 8; ++i)
    if (type & order[i]) return i;
  return 9;
}

}  // namespace

void App::draw_deck_editor(ImVec2 size) {
  // 처음 들어오면 첫 덱을 연다
  // (새 덱도 파일 없음·빈 상태라 그 조건으로 고르면 바로 첫 덱으로 덮인다)
  if (!ed_.opened) {
    ed_.opened = true;
    reload_deck_list();
    if (!decks_.empty()) ed_load(0);
    else ed_new();
  }
  const float left_w = std::clamp(size.x * 0.22f, 240.0f, 420.0f);
  const float right_w = std::clamp(size.x * 0.24f, 300.0f, 460.0f);
  draw_info_panel(ImVec2(0, 0), ImVec2(left_w, size.y));

  const ImGuiWindowFlags fixed =
      ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoTitleBar;
  ImGui::SetNextWindowPos(ImVec2(left_w, 0));
  ImGui::SetNextWindowSize(ImVec2(size.x - left_w - right_w, size.y));
  ImGui::Begin("덱", nullptr, fixed);
  ed_toolbar();
  ImGui::Separator();
  ed_deck_area();
  ImGui::End();

  ImGui::SetNextWindowPos(ImVec2(size.x - right_w, 0));
  ImGui::SetNextWindowSize(ImVec2(right_w, size.y));
  ImGui::Begin("검색", nullptr, fixed);
  ed_search_panel();
  ImGui::End();
  // 판본 줄(왼쪽 클릭으로 고른 덱 카드)은 어디든 우클릭하거나 Esc로 닫는다
  if (ImGui::IsMouseClicked(ImGuiMouseButton_Right) ||
      (ImGui::IsKeyPressed(ImGuiKey_Escape) && !ImGui::GetIO().WantTextInput))
    ed_.sel = -1;
}

void App::ed_new() {
  ed_.file = -1;
  ed_.deck = wxtest::DeckFile{};
  ed_.deck.format = "diva";
  ed_.sel = -1;
  std::snprintf(ed_.name, sizeof ed_.name, "새 덱");
  ed_.save_as[0] = 0;
  ed_.dirty = false;
  ed_.results_dirty = true;
  ed_.message.clear();
  ed_validate();
}

void App::ed_load(int file) {
  if (file < 0 || file >= static_cast<int>(decks_.size())) return;
  wxtest::DeckFile d;
  std::string err;
  if (!wxtest::load_deck(wxtest::data_dir() + "/decks/" + decks_[file] + ".json", db_, d, err)) {
    ed_.message = "읽기 실패: " + err;
    return;
  }
  ed_.file = file;
  ed_.deck = std::move(d);
  ed_.sel = -1;
  std::snprintf(ed_.name, sizeof ed_.name, "%s", ed_.deck.name.c_str());
  std::snprintf(ed_.save_as, sizeof ed_.save_as, "%s", decks_[file].c_str());
  ed_.dirty = false;
  ed_.results_dirty = true;
  ed_.message.clear();
  ed_validate();
}

bool App::ed_save(const std::string& file_stem) {
  // 파일 이름에 못 쓰는 글자는 _로
  std::string stem = file_stem;
  for (char& c : stem)
    if (std::strchr("\\/:*?\"<>|", c)) c = '_';
  if (stem.empty()) {
    ed_.message = "파일 이름이 비었음";
    return false;
  }
  ed_.deck.name = ed_.name;
  std::string err;
  if (!wxtest::save_deck(wxtest::data_dir() + "/decks/" + stem + ".json", ed_.deck, err)) {
    ed_.message = "저장 실패: " + err;
    return false;
  }
  reload_deck_list();
  ed_.file = static_cast<int>(std::find(decks_.begin(), decks_.end(), stem) - decks_.begin());
  std::snprintf(ed_.save_as, sizeof ed_.save_as, "%s", stem.c_str());
  ed_.dirty = false;
  ed_.message = "저장함: decks/" + stem + ".json";
  return true;
}

void App::ed_add(wx::Cid cid, int print) {
  const wxtest::CardEntry* e = db_.entry(cid);
  if (!e) return;
  const bool lrig = lrig_side(e->type);
  ed_fix_idx();
  auto& dst = lrig ? ed_.deck.lrig : ed_.deck.main;
  auto& idx = lrig ? ed_.deck.lrig_idx : ed_.deck.main_idx;
  // 같은 카드 옆에 넣는다
  auto it = std::find(dst.rbegin(), dst.rend(), cid);
  const auto pos = it == dst.rend() ? dst.size() : static_cast<size_t>(it.base() - dst.begin());
  dst.insert(dst.begin() + static_cast<std::ptrdiff_t>(pos), cid);
  idx.insert(idx.begin() + static_cast<std::ptrdiff_t>(pos), print);
  ed_.sel = -1;
  // 레벨 0 루리그는 비어 있는 시작 자리에 바로 둔다
  if (lrig && e->level == 0) {
    // 디바의 어시스트는 자리라 보통 루리그 카드가 온다(WXDi-D01: 타윌=놀·움르=놀)
    if ((e->type & wx::TYPE_LRIG) && !ed_.deck.start_center) ed_.deck.start_center = cid;
    else if (ed_.deck.format == "diva" && (e->type & (wx::TYPE_LRIG | wx::TYPE_ASSIST_LRIG)) &&
             ed_.deck.start_assists.size() < 2 &&
             ed_.deck.start_center != cid &&
             std::count(ed_.deck.start_assists.begin(), ed_.deck.start_assists.end(), cid) == 0)
      ed_.deck.start_assists.push_back(cid);
  }
  ed_.dirty = true;
  ed_validate();
}

void App::ed_remove(bool lrig, size_t index) {
  ed_fix_idx();
  auto& src = lrig ? ed_.deck.lrig : ed_.deck.main;
  auto& idx = lrig ? ed_.deck.lrig_idx : ed_.deck.main_idx;
  if (index >= src.size()) return;
  const wx::Cid cid = src[index];
  src.erase(src.begin() + static_cast<std::ptrdiff_t>(index));
  idx.erase(idx.begin() + static_cast<std::ptrdiff_t>(index));
  ed_.sel = -1;
  // 덱에서 다 빠지면 시작 루리그에서도 뺀다
  if (std::count(src.begin(), src.end(), cid) == 0) {
    if (ed_.deck.start_center == cid) ed_.deck.start_center = 0;
    std::erase(ed_.deck.start_assists, cid);
  }
  ed_.dirty = true;
  ed_validate();
}

void App::ed_sort() {
  auto key = [&](wx::Cid c) {
    const wxtest::CardEntry* e = db_.entry(c);
    return std::make_tuple(e ? type_rank(e->type) : 9, e ? e->level : 0, c);
  };
  ed_fix_idx();
  for (bool lrig : {true, false}) {
    auto& cards = lrig ? ed_.deck.lrig : ed_.deck.main;
    auto& idx = lrig ? ed_.deck.lrig_idx : ed_.deck.main_idx;
    std::vector<std::pair<wx::Cid, int>> v;
    for (size_t i = 0; i < cards.size(); ++i) v.emplace_back(cards[i], idx[i]);
    std::stable_sort(v.begin(), v.end(), [&](const auto& a, const auto& b) {
      return std::make_tuple(key(a.first), a.second) < std::make_tuple(key(b.first), b.second);
    });
    for (size_t i = 0; i < v.size(); ++i) std::tie(cards[i], idx[i]) = v[i];
  }
  ed_.sel = -1;
  ed_.dirty = true;
}

void App::ed_fix_idx() {
  ed_.deck.main_idx.resize(ed_.deck.main.size(), 1);
  ed_.deck.lrig_idx.resize(ed_.deck.lrig.size(), 1);
}

void App::ed_print_strip() {
  ed_fix_idx();
  auto& cards = ed_.sel_lrig ? ed_.deck.lrig : ed_.deck.main;
  auto& idx = ed_.sel_lrig ? ed_.deck.lrig_idx : ed_.deck.main_idx;
  if (ed_.sel < 0 || ed_.sel >= static_cast<int>(cards.size())) {
    ed_.sel = -1;
    return;
  }
  const wx::Cid cid = cards[ed_.sel];
  const int n = db_.print_count(cid);
  int& cur = idx[ed_.sel];
  ImGui::Text("판본 %d / %d", cur, n);
  if (n > 1) {
    ImGui::SameLine();
    if (ImGui::SmallButton("이 카드 전부"))  // 덱의 같은 카드를 모두 이 판본으로
      for (size_t i = 0; i < cards.size(); ++i)
        if (cards[i] == cid && idx[i] != cur) {
          idx[i] = cur;
          ed_.dirty = true;
        }
  }
  const float th = ImGui::GetTextLineHeight() * 4.5f, tw = th / kRatio;
  ImGui::BeginChild("prints", ImVec2(0, th + ImGui::GetStyle().ScrollbarSize + 8), ImGuiChildFlags_None,
                    ImGuiWindowFlags_HorizontalScrollbar);
  ImDrawList* dl = ImGui::GetWindowDrawList();
  for (int i = 1; i <= n; ++i) {
    if (i > 1) ImGui::SameLine(0, 4);
    const ImVec2 a = ImGui::GetCursorScreenPos(), b(a.x + tw, a.y + th);
    ImGui::PushID(i);
    if (ImGui::InvisibleButton("p", ImVec2(tw, th)) && cur != i) {
      cur = i;
      ed_.dirty = true;
    }
    const bool hovered = ImGui::IsItemHovered();
    ImGui::PopID();
    if (!ImGui::IsRectVisible(a, b)) continue;  // 화면 밖 판본은 그림을 읽지 않는다
    const Texture& t = tex_.card(cid, i);
    if (t.id) dl->AddImage(t.id, a, b);
    else dl->AddRectFilled(a, b, IM_COL32(60, 66, 84, 255));
    const ImU32 col = i == cur ? IM_COL32(120, 220, 120, 255) : hovered ? IM_COL32(255, 255, 255, 160) : IM_COL32(0, 0, 0, 0);
    if (i == cur || hovered) dl->AddRect(a, b, col, 0, 0, 2.0f);
    if (hovered) {
      preview_cid_ = preview_idx_cid_ = cid;
      preview_idx_ = i;
    }
  }
  if (ImGui::IsWindowAppearing()) ImGui::SetScrollX((cur - 1) * (tw + 4));  // 고른 판본이 보이게
  ImGui::EndChild();
}

void App::ed_toolbar() {
  // 1줄: 덱 고르기와 파일 조작
  ImGui::SetNextItemWidth(260);
  const char* cur = ed_.file >= 0 && ed_.file < static_cast<int>(decks_.size()) ? decks_[ed_.file].c_str() : "(새 덱)";
  if (ImGui::BeginCombo("##decks", cur)) {
    for (int i = 0; i < static_cast<int>(decks_.size()); ++i)
      if (ImGui::Selectable(decks_[i].c_str(), i == ed_.file)) {
        if (ed_.dirty) ed_.pending_file = i;
        else ed_load(i);
      }
    ImGui::EndCombo();
  }
  ImGui::SameLine();
  if (ImGui::Button("새 덱")) {
    if (ed_.dirty) ed_.pending_file = -1;
    else ed_new();
  }
  ImGui::SameLine();
  if (ImGui::Button("저장")) {
    if (ed_.file >= 0) ed_save(decks_[ed_.file]);
    else ImGui::OpenPopup("save_as");
  }
  ImGui::SameLine();
  if (ImGui::Button("다른 이름으로")) ImGui::OpenPopup("save_as");
  ImGui::SameLine();
  ImGui::BeginDisabled(ed_.file < 0);
  if (ImGui::Button("삭제")) ImGui::OpenPopup("delete");
  ImGui::EndDisabled();
  ImGui::SameLine();
  if (ImGui::Button("메뉴로")) {
    if (ed_.dirty) ed_.pending_file = -3;  // -3 = 메뉴로
    else screen_ = Screen::Menu;
  }

  // 2줄: 덱 이름·포맷·정렬·비우기
  ImGui::SetNextItemWidth(260);
  if (ImGui::InputText("##name", ed_.name, sizeof ed_.name)) ed_.dirty = true;
  ImGui::SameLine();
  int f = format_index(ed_.deck.format);
  ImGui::SetNextItemWidth(140);
  if (ImGui::Combo("##format", &f, kFormatLabels, 3)) {
    ed_.deck.format = kFormats[f];
    ed_.dirty = true;
    ed_.results_dirty = true;
    ed_validate();
  }
  ImGui::SameLine();
  if (ImGui::Button("정렬")) ed_sort();
  ImGui::SameLine();
  if (ImGui::Button("비우기")) {
    ed_.deck.lrig.clear();
    ed_.deck.main.clear();
    ed_.deck.start_center = 0;
    ed_.deck.start_assists.clear();
    ed_.dirty = true;
    ed_validate();
  }
  ImGui::SameLine();
  if (ed_.dirty) ImGui::TextColored(ImVec4(1, 0.8f, 0.3f, 1), "저장 안 함");
  else if (!ed_.message.empty()) ImGui::TextDisabled("%s", ed_.message.c_str());

  // 다른 이름으로 저장
  if (ImGui::BeginPopup("save_as")) {
    ImGui::TextUnformatted("파일 이름(decks/○○.json)");
    if (ImGui::IsWindowAppearing()) ImGui::SetKeyboardFocusHere();
    const bool enter = ImGui::InputText("##file", ed_.save_as, sizeof ed_.save_as, ImGuiInputTextFlags_EnterReturnsTrue);
    if ((ImGui::Button("저장") || enter) && ed_save(ed_.save_as)) ImGui::CloseCurrentPopup();
    ImGui::SameLine();
    if (ImGui::Button("취소")) ImGui::CloseCurrentPopup();
    ImGui::EndPopup();
  }
  if (ImGui::BeginPopup("delete")) {
    ImGui::Text("decks/%s.json 을 지울까?", ed_.file >= 0 ? decks_[ed_.file].c_str() : "");
    if (ImGui::Button("지우기")) {
      std::error_code ec;
      std::filesystem::remove(wxtest::data_dir() + "/decks/" + decks_[ed_.file] + ".json", ec);
      reload_deck_list();
      if (!decks_.empty()) ed_load(0);
      else ed_new();
      ImGui::CloseCurrentPopup();
    }
    ImGui::SameLine();
    if (ImGui::Button("취소")) ImGui::CloseCurrentPopup();
    ImGui::EndPopup();
  }
  // 저장 안 한 변경이 있을 때 넘어가기
  if (ed_.pending_file != -2) ImGui::OpenPopup("discard");
  if (ImGui::BeginPopupModal("discard", nullptr, ImGuiWindowFlags_AlwaysAutoResize)) {
    ImGui::TextUnformatted("저장하지 않은 변경이 있다. 버리고 넘어갈까?");
    if (ImGui::Button("버리기")) {
      const int to = ed_.pending_file;
      ed_.pending_file = -2;
      ed_.dirty = false;
      if (to == -3) screen_ = Screen::Menu;
      else if (to == -1) ed_new();
      else ed_load(to);
      ImGui::CloseCurrentPopup();
    }
    ImGui::SameLine();
    if (ImGui::Button("취소")) {
      ed_.pending_file = -2;
      ImGui::CloseCurrentPopup();
    }
    ImGui::EndPopup();
  }
}

// 덱 그림 한 묶음. 우클릭 = 빼기(판본 줄을 연 카드면 닫기), 레벨 0 루리그 클릭 = 시작 루리그 메뉴
void App::ed_card_grid(const char* id, std::vector<wx::Cid>& cards, bool lrig, int per_row) {
  ImGui::PushID(id);
  const float pad = 4.0f;
  const float w = std::floor((ImGui::GetContentRegionAvail().x - pad * (per_row - 1)) / per_row);
  const float h = w * kRatio;
  const ImVec2 o = ImGui::GetCursorScreenPos();
  ImDrawList* dl = ImGui::GetWindowDrawList();
  const int rows = std::max(1, (static_cast<int>(cards.size()) + per_row - 1) / per_row);
  // 빈 자리 배경
  dl->AddRectFilled(o, ImVec2(o.x + per_row * (w + pad) - pad, o.y + rows * (h + pad) - pad), IM_COL32(24, 28, 40, 255), 4.0f);
  int remove = -1;
  for (size_t i = 0; i < cards.size(); ++i) {
    const wx::Cid cid = cards[i];
    const int print = ed_.deck.print_of(lrig, i);
    const ImVec2 a(o.x + (i % per_row) * (w + pad), o.y + (i / per_row) * (h + pad));
    const ImVec2 b(a.x + w, a.y + h);
    const Texture& t = tex_.card(cid, print);
    if (t.id) dl->AddImage(t.id, a, b);
    else {
      dl->AddRectFilled(a, b, IM_COL32(60, 66, 84, 255));
      const wxtest::CardEntry* e = db_.entry(cid);
      if (e) dl->AddText(ImGui::GetFont(), ImGui::GetFontSize() * 0.7f, ImVec2(a.x + 3, a.y + 3), IM_COL32_WHITE, e->name.c_str(),
                         nullptr, w - 6);
    }
    // 시작 루리그 표시
    const bool center = lrig && cid == ed_.deck.start_center;
    const bool assist = lrig && std::count(ed_.deck.start_assists.begin(), ed_.deck.start_assists.end(), cid) > 0;
    if (center || assist) {
      dl->AddRect(a, b, center ? IM_COL32(255, 200, 60, 255) : IM_COL32(120, 200, 255, 255), 0, 0, 3.0f);
      const char* tag = center ? "센터" : "어시스트";
      const float fs = ImGui::GetFontSize() * 0.75f;
      const ImVec2 ts = ImGui::GetFont()->CalcTextSizeA(fs, FLT_MAX, 0, tag);
      dl->AddRectFilled(ImVec2(a.x, b.y - ts.y - 4), ImVec2(a.x + ts.x + 8, b.y), IM_COL32(0, 0, 0, 200));
      dl->AddText(ImGui::GetFont(), fs, ImVec2(a.x + 4, b.y - ts.y - 2), IM_COL32_WHITE, tag);
    }
    ImGui::SetCursorScreenPos(a);
    ImGui::PushID(static_cast<int>(i));
    ImGui::InvisibleButton("c", ImVec2(w, h), ImGuiButtonFlags_MouseButtonLeft | ImGuiButtonFlags_MouseButtonRight);
    if (ImGui::IsItemHovered()) {
      preview_cid_ = preview_idx_cid_ = cid;
      preview_idx_ = print;
      preview_handle_ = 0;
      dl->AddRect(a, b, IM_COL32(255, 255, 255, 160), 0, 0, 2.0f);
    }
    if (ed_.sel == static_cast<int>(i) && ed_.sel_lrig == lrig) dl->AddRect(a, b, IM_COL32(120, 220, 120, 255), 0, 0, 3.0f);
    // 판본 줄을 열어 둔 그 카드의 우클릭은 닫기(draw_deck_editor), 나머지는 빼기
    if (ImGui::IsItemClicked(ImGuiMouseButton_Right) && !(ed_.sel == static_cast<int>(i) && ed_.sel_lrig == lrig))
      remove = static_cast<int>(i);
    // 왼쪽 클릭: 이 장을 골라 카드 정보 패널에서 판본을 바꾼다(레벨 0 루리그는 시작 루리그 메뉴도)
    if (ImGui::IsItemClicked(ImGuiMouseButton_Left)) {
      ed_.sel = static_cast<int>(i);
      ed_.sel_lrig = lrig;
    }
    if (lrig && ImGui::IsItemClicked(ImGuiMouseButton_Left)) {
      const wxtest::CardEntry* e = db_.entry(cid);
      if (e && e->level == 0 && (e->type & (wx::TYPE_LRIG | wx::TYPE_ASSIST_LRIG))) {
        ed_.start_menu = cid;
        ImGui::OpenPopup("start");
      }
    }
    ImGui::PopID();
  }
  ImGui::SetCursorScreenPos(o);
  ImGui::Dummy(ImVec2(per_row * (w + pad) - pad, rows * (h + pad) - pad));
  // 시작 루리그 메뉴(레벨 0 루리그)
  if (lrig && ImGui::BeginPopup("start")) {
    const wx::Cid c = ed_.start_menu;
    const wxtest::CardEntry* e = db_.entry(c);
    ImGui::TextDisabled("%s", e ? e->name.c_str() : "");
    auto& as = ed_.deck.start_assists;
    const bool in_assist = std::count(as.begin(), as.end(), c) > 0;
    if (e && (e->type & wx::TYPE_LRIG) && ImGui::Selectable("시작 센터 루리그로")) {
      std::erase(as, c);
      ed_.deck.start_center = c;
      ed_.dirty = true;
    }
    if (e && !in_assist && as.size() < 2 && ImGui::Selectable("시작 어시스트 루리그로")) {
      if (ed_.deck.start_center == c) ed_.deck.start_center = 0;
      as.push_back(c);
      ed_.dirty = true;
    }
    if ((ed_.deck.start_center == c || in_assist) && ImGui::Selectable("시작 루리그에서 빼기")) {
      if (ed_.deck.start_center == c) ed_.deck.start_center = 0;
      std::erase(as, c);
      ed_.dirty = true;
    }
    if (ed_.dirty) ed_validate();
    ImGui::EndPopup();
  }
  ImGui::PopID();
  if (remove >= 0) ed_remove(lrig, static_cast<size_t>(remove));
}

void App::ed_deck_area() {
  ImGui::BeginChild("deck_area");
  int lb = 0;
  for (wx::Cid c : ed_.deck.main)
    if (const wxtest::CardEntry* e = db_.entry(c); e && e->life_burst) ++lb;
  ImGui::Text("루리그 덱  %zu장", ed_.deck.lrig.size());
  ImGui::SameLine();
  ImGui::TextDisabled("(카드를 누르면 왼쪽에서 판본 바꾸기, 레벨 0 루리그는 시작 루리그 지정, 우클릭으로 빼기)");
  ed_card_grid("lrig", ed_.deck.lrig, true, 12);
  ImGui::Spacing();
  ImGui::Text("메인 덱  %zu장   라이프 버스트 %d장", ed_.deck.main.size(), lb);
  ed_card_grid("main", ed_.deck.main, false, 10);
  ImGui::Spacing();
  if (ed_.problems.empty()) {
    ImGui::TextColored(ImVec4(0.5f, 0.9f, 0.5f, 1), "덱 검사 통과 (%s)", kFormatLabels[format_index(ed_.deck.format)]);
  } else {
    for (const auto& p : ed_.problems) ImGui::TextColored(ImVec4(1, 0.5f, 0.4f, 1), "· %s", p.c_str());
  }
  ImGui::EndChild();
}

void App::ed_refresh_results() {
  ed_.results.clear();
  // 검색어: 공백으로 나눈 낱말이 모두 들어 있으면(ASCII는 대소문자 무시)
  std::vector<std::string> words;
  {
    std::string q = ed_.query, w;
    std::transform(q.begin(), q.end(), q.begin(),
                   [](char ch) { return static_cast<char>(std::tolower(static_cast<unsigned char>(ch))); });
    for (char ch : q + " ") {
      if (ch == ' ') {
        if (!w.empty()) words.push_back(w);
        w.clear();
      } else {
        w += ch;
      }
    }
  }
  const int f = format_index(ed_.deck.format);
  const uint32_t tbits = kTypeFilters[ed_.type].bits;
  auto in = [](int v, int lo, int hi) { return (lo < 0 || v >= lo) && (hi < 0 || v <= hi); };
  const bool leveled = ed_.level_min >= 0 || ed_.level_max >= 0;
  const bool powered = ed_.power_min >= 0 || ed_.power_max >= 0;
  for (const auto& e : db_.all_cards()) {
    if (tbits && !(e.type & tbits)) continue;
    if (ed_.colors && !(e.color & ed_.colors)) continue;
    // 레벨·파워 조건이 있으면 그 값이 없는 종류(아츠·스펠 등)는 뺀다
    if (leveled && (!(e.type & (wx::TYPE_LRIG | wx::TYPE_ASSIST_LRIG | wx::TYPE_SIGNI | wx::TYPE_RESONA)) ||
                    !in(e.level, ed_.level_min, ed_.level_max)))
      continue;
    if (powered && (!(e.type & (wx::TYPE_SIGNI | wx::TYPE_RESONA)) || !in(e.power, ed_.power_min, ed_.power_max))) continue;
    if (!in(e.cost, ed_.cost_min, ed_.cost_max)) continue;
    if (!ed_.signi_class.empty() &&
        std::find(e.signi_classes.begin(), e.signi_classes.end(), ed_.signi_class) == e.signi_classes.end())
      continue;
    if (ed_.lrig_type && std::find(e.lrig_types.begin(), e.lrig_types.end(), ed_.lrig_type) == e.lrig_types.end()) continue;
    if (ed_.limit == 0 && !e.limit_cond.empty()) continue;
    if (ed_.limit > 0 &&
        std::find(e.limit_cond.begin(), e.limit_cond.end(), static_cast<uint32_t>(ed_.limit)) == e.limit_cond.end())
      continue;
    if ((ed_.life_burst == 1 && !e.life_burst) || (ed_.life_burst == 2 && e.life_burst)) continue;
    if (ed_.guard && !e.guard) continue;
    if (ed_.timing && !(e.timing & ed_.timing)) continue;
    if (ed_.scripted && (e.cid >= ed_.has_script.size() || !ed_.has_script[e.cid])) continue;
    if (ed_.pool && f != 2) {
      // 포맷 FAQ: 아이콘이 붙은 카드와 같은 이름이면 이전 카드도 쓸 수 있다. 레벨 0 루리그 예외는 덱 검사가 본다
      const uint32_t bits = f == 0 ? wxtest::kFormatDiva : (wxtest::kFormatDiva | wxtest::kFormatKey);
      const bool lrig0 = (e.type & wx::TYPE_LRIG) && e.level == 0;
      if (!(e.formats & bits) && !db_.name_has_format(e.name_key(), bits) && !(lrig0 && f == 1)) continue;
    }
    bool ok = true;
    for (const auto& w : words)
      if (e.search.find(w) == std::string::npos) {
        ok = false;
        break;
      }
    if (ok) ed_.results.push_back(e.cid);
  }
  if (ed_.sort) {
    auto key = [&](wx::Cid c) {
      const wxtest::CardEntry* e = db_.entry(c);
      return ed_.sort == 1 ? e->level : ed_.sort == 2 ? e->power : e->cost;
    };
    if (ed_.sort == 4)
      std::stable_sort(ed_.results.begin(), ed_.results.end(),
                       [&](wx::Cid a, wx::Cid b) { return db_.entry(a)->name < db_.entry(b)->name; });
    else
      std::stable_sort(ed_.results.begin(), ed_.results.end(), [&](wx::Cid a, wx::Cid b) { return key(a) < key(b); });
  }
  ed_.results_dirty = false;
}

// 필터 선택지: 시그니 클래스·루리그 타입 목록, 스크립트가 있는 cid
void App::ed_build_lists() {
  ed_.lists_ready = true;
  std::set<std::string> classes;
  std::map<uint32_t, std::string> types;
  for (const auto& e : db_.all_cards()) {
    for (const auto& c : e.signi_classes) classes.insert(c);
    for (uint32_t t : e.lrig_types) types[t] = db_.lrig_type_name(t);
  }
  ed_.class_list.assign(classes.begin(), classes.end());
  ed_.lrig_type_list.assign(types.begin(), types.end());
  std::sort(ed_.lrig_type_list.begin(), ed_.lrig_type_list.end(),
            [](const auto& a, const auto& b) { return a.second < b.second; });
  ed_.has_script.clear();
  namespace fs = std::filesystem;
  for (const auto& dir : wxtest::data_dirs()) {
    std::error_code ec;
    for (const auto& f : fs::directory_iterator(fs::u8path(dir + "/script"), ec)) {
      const std::string n = f.path().filename().string();
      if (n.size() < 6 || n[0] != 'c' || n.substr(n.size() - 4) != ".lua") continue;
      const unsigned long cid = std::strtoul(n.c_str() + 1, nullptr, 10);
      if (!cid || cid > 50'000'000) continue;
      if (ed_.has_script.size() <= cid) ed_.has_script.resize(cid + 1);
      ed_.has_script[cid] = true;
    }
  }
}

namespace {
// 「최소~최대」 숫자 칸 두 개. -1 = 제한 없음(빈 칸으로 보인다)
bool range_input(const char* label, int& lo, int& hi) {
  bool changed = false;
  ImGui::PushID(label);
  ImGui::TextUnformatted(label);
  ImGui::SameLine(90);
  auto one = [&](const char* id, int& v) {
    char buf[16] = "";
    if (v >= 0) std::snprintf(buf, sizeof buf, "%d", v);
    ImGui::SetNextItemWidth(70);
    if (ImGui::InputTextWithHint(id, "-", buf, sizeof buf, ImGuiInputTextFlags_CharsDecimal)) {
      v = buf[0] ? std::atoi(buf) : -1;
      changed = true;
    }
  };
  one("##lo", lo);
  ImGui::SameLine();
  ImGui::TextUnformatted("~");
  ImGui::SameLine();
  one("##hi", hi);
  ImGui::PopID();
  return changed;
}
}  // namespace

void App::ed_search_panel() {
  ImGui::SetNextItemWidth(-1);
  if (ImGui::InputTextWithHint("##q", "이름·클래스·텍스트", ed_.query, sizeof ed_.query)) ed_.results_dirty = true;
  if (!ed_.lists_ready && db_.is_open()) ed_build_lists();
  bool& dirty = ed_.results_dirty;
  ImGui::SetNextItemWidth(150);
  const char* labels[std::size(kTypeFilters)];
  for (size_t i = 0; i < std::size(kTypeFilters); ++i) labels[i] = kTypeFilters[i].label;
  if (ImGui::Combo("종류", &ed_.type, labels, static_cast<int>(std::size(kTypeFilters)))) dirty = true;
  ImGui::SameLine();
  ImGui::SetNextItemWidth(110);
  const char* sorts[] = {"번호순", "레벨순", "파워순", "코스트순", "이름순"};
  if (ImGui::Combo("정렬", &ed_.sort, sorts, 5)) dirty = true;
  for (const auto& c : kColors) {
    ImGui::PushStyleColor(ImGuiCol_Text, c.col);
    bool on = (ed_.colors & c.bit) != 0;
    if (ImGui::Checkbox(c.label, &on)) {
      ed_.colors ^= c.bit;
      dirty = true;
    }
    ImGui::PopStyleColor();
    ImGui::SameLine();
  }
  ImGui::NewLine();
  if (ImGui::Checkbox("덱 포맷에서 쓸 수 있는 카드만", &ed_.pool)) dirty = true;
  ImGui::SameLine();
  if (ImGui::Checkbox("구현된 카드만", &ed_.scripted)) dirty = true;
  if (ImGui::IsItemHovered()) ImGui::SetTooltip("스크립트가 있는 카드(능력 없는 카드는 스크립트가 없어도 쓸 수 있다)");

  if (ImGui::CollapsingHeader("상세 필터")) {
    dirty |= range_input("레벨", ed_.level_min, ed_.level_max);
    dirty |= range_input("파워", ed_.power_min, ed_.power_max);
    dirty |= range_input("코스트", ed_.cost_min, ed_.cost_max);
    if (ImGui::IsItemHovered()) ImGui::SetTooltip("에나 코스트 합계(그로우 코스트 포함, 《無》도 센다)");

    // 시그니 클래스
    ImGui::TextUnformatted("클래스");
    ImGui::SameLine(90);
    ImGui::SetNextItemWidth(-1);
    if (ImGui::BeginCombo("##class", ed_.signi_class.empty() ? "전부" : ed_.signi_class.c_str(), ImGuiComboFlags_HeightLarge)) {
      if (ImGui::Selectable("전부", ed_.signi_class.empty())) ed_.signi_class.clear(), dirty = true;
      for (const auto& c : ed_.class_list)
        if (ImGui::Selectable(c.c_str(), c == ed_.signi_class)) ed_.signi_class = c, dirty = true;
      ImGui::EndCombo();
    }
    // 루리그 타입·한정 조건
    auto type_name = [&](uint32_t id) -> std::string {
      for (const auto& [t, n] : ed_.lrig_type_list)
        if (t == id) return n;
      return "?";
    };
    ImGui::TextUnformatted("루리그 타입");
    ImGui::SameLine(90);
    ImGui::SetNextItemWidth(-1);
    if (ImGui::BeginCombo("##ltype", ed_.lrig_type ? type_name(ed_.lrig_type).c_str() : "전부", ImGuiComboFlags_HeightLarge)) {
      if (ImGui::Selectable("전부", ed_.lrig_type == 0)) ed_.lrig_type = 0, dirty = true;
      for (const auto& [t, n] : ed_.lrig_type_list)
        if (ImGui::Selectable(n.c_str(), t == ed_.lrig_type)) ed_.lrig_type = t, dirty = true;
      ImGui::EndCombo();
    }
    ImGui::TextUnformatted("한정 조건");
    ImGui::SameLine(90);
    ImGui::SetNextItemWidth(-1);
    const std::string lim = ed_.limit < 0 ? "전부" : ed_.limit == 0 ? "한정 없음" : type_name(static_cast<uint32_t>(ed_.limit)) + " 한정";
    if (ImGui::BeginCombo("##limit", lim.c_str(), ImGuiComboFlags_HeightLarge)) {
      if (ImGui::Selectable("전부", ed_.limit < 0)) ed_.limit = -1, dirty = true;
      if (ImGui::Selectable("한정 없음", ed_.limit == 0)) ed_.limit = 0, dirty = true;
      for (const auto& [t, n] : ed_.lrig_type_list)
        if (ImGui::Selectable((n + " 한정").c_str(), static_cast<int64_t>(t) == ed_.limit)) ed_.limit = t, dirty = true;
      ImGui::EndCombo();
    }
    // 라이프 버스트·가드
    ImGui::TextUnformatted("라이프 버스트");
    ImGui::SameLine(90);
    dirty |= ImGui::RadioButton("전부##lb", &ed_.life_burst, 0);
    ImGui::SameLine();
    dirty |= ImGui::RadioButton("있음##lb", &ed_.life_burst, 1);
    ImGui::SameLine();
    dirty |= ImGui::RadioButton("없음##lb", &ed_.life_burst, 2);
    ImGui::SameLine();
    dirty |= ImGui::Checkbox("가드", &ed_.guard);
    // 사용 타이밍(아츠·스펠·【起】)
    ImGui::TextUnformatted("사용 타이밍");
    ImGui::SameLine(90);
    const struct {
      uint32_t bit;
      const char* label;
    } timings[] = {{1u << 0, "메인"}, {1u << 1, "어택"}, {1u << 2, "스펠 컷인"}};
    for (const auto& t : timings) {
      bool on = (ed_.timing & t.bit) != 0;
      if (ImGui::Checkbox(t.label, &on)) {
        ed_.timing ^= t.bit;
        dirty = true;
      }
      ImGui::SameLine();
    }
    ImGui::NewLine();
    if (ImGui::Button("필터 초기화")) {
      ed_.type = ed_.colors = ed_.life_burst = ed_.sort = 0;
      ed_.level_min = ed_.level_max = ed_.power_min = ed_.power_max = ed_.cost_min = ed_.cost_max = -1;
      ed_.signi_class.clear();
      ed_.lrig_type = 0;
      ed_.limit = -1;
      ed_.guard = ed_.scripted = false;
      ed_.timing = 0;
      dirty = true;
    }
  }
  if (ed_.results_dirty) ed_refresh_results();
  ImGui::TextDisabled("%zu장  (우클릭·더블클릭으로 넣기, 휠클릭으로 판본 고르기)", ed_.results.size());
  ImGui::Separator();

  bool open_picker = false;
  ImGui::BeginChild("results");
  const float row_h = 64.0f;
  ImGuiListClipper clip;
  clip.Begin(static_cast<int>(ed_.results.size()), row_h);
  while (clip.Step()) {
    for (int i = clip.DisplayStart; i < clip.DisplayEnd; ++i) {
      const wx::Cid cid = ed_.results[i];
      const wxtest::CardEntry* e = db_.entry(cid);
      if (!e) continue;
      ImGui::PushID(static_cast<int>(cid));
      const ImVec2 a = ImGui::GetCursorScreenPos();
      ImGui::Selectable("##row", false, ImGuiSelectableFlags_AllowDoubleClick, ImVec2(0, row_h - 4));
      const bool hovered = ImGui::IsItemHovered();
      if (hovered) {
        preview_cid_ = cid;
        preview_idx_cid_ = 0;  // 검색 결과는 기본 그림
        preview_handle_ = 0;
      }
      if ((hovered && ImGui::IsMouseDoubleClicked(ImGuiMouseButton_Left)) || ImGui::IsItemClicked(ImGuiMouseButton_Right))
        ed_add(cid);
      if (ImGui::IsItemClicked(ImGuiMouseButton_Middle) && db_.print_count(cid) > 1) {
        ed_.pick_cid = cid;
        open_picker = true;
      }
      ImDrawList* dl = ImGui::GetWindowDrawList();
      const float th = row_h - 6, tw = th / kRatio;
      const Texture& t = tex_.card(cid);
      if (t.id) dl->AddImage(t.id, ImVec2(a.x + 2, a.y + 1), ImVec2(a.x + 2 + tw, a.y + 1 + th));
      else dl->AddRectFilled(ImVec2(a.x + 2, a.y + 1), ImVec2(a.x + 2 + tw, a.y + 1 + th), IM_COL32(60, 66, 84, 255));
      const float tx = a.x + tw + 10;
      dl->AddText(ImVec2(tx, a.y + 4), IM_COL32_WHITE, e->name.c_str());
      std::string line = type_label(e->type) + "  " + color_label(e->color);
      if (e->type & (wx::TYPE_LRIG | wx::TYPE_ASSIST_LRIG | wx::TYPE_SIGNI | wx::TYPE_RESONA))
        line += "  Lv" + std::to_string(e->level);
      if (e->type & (wx::TYPE_SIGNI | wx::TYPE_RESONA)) line += "  " + std::to_string(e->power);
      if (e->type & wx::TYPE_LRIG) line += "  리미트 " + std::to_string(e->limit);
      if (e->life_burst) line += "  LB";
      dl->AddText(ImVec2(tx, a.y + 4 + ImGui::GetFontSize() + 2), IM_COL32(150, 158, 180, 255), line.c_str());
      std::string tag = "[" + std::to_string(e->cid) + "]";
      if (const int n = db_.print_count(cid); n > 1) tag += "  일러 " + std::to_string(n) + "종";
      dl->AddText(ImVec2(tx, a.y + 4 + (ImGui::GetFontSize() + 2) * 2), IM_COL32(110, 118, 140, 255), tag.c_str());
      ImGui::PopID();
    }
  }
  ImGui::EndChild();
  if (open_picker) ImGui::OpenPopup("print_picker");
  ed_print_picker();
}

// 판본 목록 팝업. 왼쪽 클릭 = 그 판본으로 한 장 넣기(팝업은 열어 둔다), 바깥 클릭·Esc = 닫기
void App::ed_print_picker() {
  if (!ImGui::BeginPopup("print_picker")) return;
  const wx::Cid cid = ed_.pick_cid;
  const wxtest::CardEntry* e = db_.entry(cid);
  const int n = db_.print_count(cid);
  ImGui::TextUnformatted(e ? e->name.c_str() : "");
  ImGui::SameLine();
  ImGui::TextDisabled("일러 %d종  (누르면 그 판본으로 넣기)", n);
  const float th = ImGui::GetTextLineHeight() * 9.0f, tw = th / kRatio;
  const int per_row = std::clamp(n, 1, 6);
  ImDrawList* dl = ImGui::GetWindowDrawList();
  for (int i = 1; i <= n; ++i) {
    if ((i - 1) % per_row) ImGui::SameLine(0, 4);
    const ImVec2 a = ImGui::GetCursorScreenPos(), b(a.x + tw, a.y + th);
    ImGui::PushID(i);
    if (ImGui::InvisibleButton("p", ImVec2(tw, th))) ed_add(cid, i);
    const bool hovered = ImGui::IsItemHovered();
    ImGui::PopID();
    const Texture& t = tex_.card(cid, i);
    if (t.id) dl->AddImage(t.id, a, b);
    else dl->AddRectFilled(a, b, IM_COL32(60, 66, 84, 255));
    const std::string num = std::to_string(i);
    dl->AddRectFilled(a, ImVec2(a.x + ImGui::CalcTextSize(num.c_str()).x + 8, a.y + ImGui::GetTextLineHeight() + 4),
                      IM_COL32(0, 0, 0, 200));
    dl->AddText(ImVec2(a.x + 4, a.y + 2), IM_COL32_WHITE, num.c_str());
    if (hovered) {
      dl->AddRect(a, b, IM_COL32(255, 255, 255, 160), 0, 0, 2.0f);
      preview_cid_ = preview_idx_cid_ = cid;
      preview_idx_ = i;
      preview_handle_ = 0;
    }
  }
  ImGui::EndPopup();
}

// 덱 검사: formats/<포맷>.lua
void App::ed_validate() {
  const wxtest::DeckCheck r = wxtest::check_deck(db_, ed_.deck);
  ed_.problems = r.problems;
  if (!r.error.empty()) ed_.problems.insert(ed_.problems.begin(), "검사 스크립트 오류: " + r.error);
}

}  // namespace wxframe
