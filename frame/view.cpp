// 화면. 한 PC에서 두 사람이 번갈아 하는 핫시트. 요청을 받은 플레이어의 시점으로 그린다.
#include "view.h"

#include <imgui.h>

#include <algorithm>
#include <cstdio>
#include <filesystem>
#include <random>

namespace wxframe {

namespace {


std::string power_text(const wx_card_info& c) {
  if (!c.known) return "";
  char buf[64] = "";
  if (c.type & 0x2) std::snprintf(buf, sizeof buf, "Lv%d  %d", c.level, c.power);  // 시그니
  else if (c.type & (0x1 | 0x10)) std::snprintf(buf, sizeof buf, "Lv%d  리미트 %d", c.level, c.limit);
  return buf;
}

std::string state_text(const wx_card_info& c) {
  std::string s;
  if (c.flags & 1) s += "[다운]";
  if (c.flags & 2) s += "[동결]";
  if (c.keywords & WX_KW_LANCER) s += "[ランサー]";
  if (c.keywords & WX_KW_DOUBLE_CRUSH) s += "[ダブルクラッシュ]";
  if (c.keywords & WX_KW_ASSASSIN) s += "[アサシン]";
  if (c.keywords & WX_KW_CANNOT_ATTACK) s += "[어택 불가]";
  if (c.n_under) s += "[아래 " + std::to_string(c.n_under) + "]";
  return s;
}

}  // namespace

App::App(Textures& tex) : tex_(tex), game_(db_) {
  db_.open(wxtest::data_dir() + "/expansions/official/wixoss.db");
  std::error_code ec;
  for (const auto& e : std::filesystem::directory_iterator(wxtest::data_dir() + "/decks", ec))
    if (e.path().extension() == ".json") decks_.push_back(e.path().stem().string());
  std::sort(decks_.begin(), decks_.end());
  if (decks_.size() > 1) deck_[1] = 1;
}

void App::draw() {
  const ImVec2 size = ImGui::GetIO().DisplaySize;
  if (!game_.running()) {
    draw_setup(size);
    return;
  }
  // 고르는 사람이 바뀌면 그 사람 시점으로. 핫시트라 넘기는 화면을 먼저 보여 준다
  if (follow_ && game_.request() && game_.request()->player != viewer_ && pass_to_ < 0) {
    pass_to_ = game_.request()->player;
    picks_.clear();
  }
  if (pass_to_ >= 0) {
    if (!pass_screen_) {
      viewer_ = pass_to_;
      pass_to_ = -1;
    } else {
      draw_pass(size);
      return;
    }
  }
  // 왼쪽: 카드 미리보기 + 탭, 가운데: 장, 오른쪽: 요청
  const ImGuiWindowFlags fixed = ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoCollapse;
  const float left_w = std::max(320.0f, size.x * 0.22f);
  const float right_w = std::max(300.0f, size.x * 0.20f);
  draw_info_panel(ImVec2(0, 0), ImVec2(left_w, size.y));

  draw_field(ImVec2(left_w, 0), ImVec2(size.x - left_w - right_w, size.y));

  ImGui::SetNextWindowPos(ImVec2(size.x - right_w, 0));
  ImGui::SetNextWindowSize(ImVec2(right_w, size.y));
  ImGui::Begin("요청", nullptr, fixed);
  draw_request();
  ImGui::End();
}

void App::draw_setup(ImVec2 size) {
  ImGui::SetNextWindowPos(ImVec2(size.x * 0.5f, size.y * 0.5f), ImGuiCond_Always, ImVec2(0.5f, 0.5f));
  ImGui::Begin("새 대전", nullptr, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoCollapse);
  if (!db_.is_open()) {
    ImGui::TextColored(ImVec4(1, 0.4f, 0.4f, 1), "카드 DB를 못 열었음: %s", db_.error().c_str());
    ImGui::TextUnformatted("python tools/build_db.py 로 먼저 만든다");
  }
  for (int p = 0; p < 2; ++p) {
    ImGui::PushID(p);
    const char* cur = deck_[p] < static_cast<int>(decks_.size()) ? decks_[deck_[p]].c_str() : "";
    if (ImGui::BeginCombo(p == 0 ? "P1 덱" : "P2 덱", cur)) {
      for (int i = 0; i < static_cast<int>(decks_.size()); ++i)
        if (ImGui::Selectable(decks_[i].c_str(), i == deck_[p])) deck_[p] = i;
      ImGui::EndCombo();
    }
    ImGui::PopID();
  }
  ImGui::InputScalar("시드", ImGuiDataType_U64, &seed_);
  ImGui::Checkbox("연습 모드(되돌리기)", &practice_);
  ImGui::Checkbox("시점이 바뀔 때 넘기는 화면", &pass_screen_);
  if (ImGui::Button("시작")) quick_start();
  if (!error_.empty()) ImGui::TextColored(ImVec4(1, 0.4f, 0.4f, 1), "%s", error_.c_str());
  ImGui::End();
}

void App::quick_start() {
  if (decks_.empty()) return;
  wxtest::DeckFile d[2];
  error_.clear();
  for (int p = 0; p < 2 && error_.empty(); ++p)
    wxtest::load_deck(wxtest::data_dir() + "/decks/" + decks_[deck_[p]] + ".json", db_, d[p], error_);
  if (error_.empty() && game_.start(d[0], d[1], seed_, practice_, error_)) {
    viewer_ = game_.request() ? game_.request()->player : 0;
    picks_.clear();
    open_zone_ = -1;
  }
}

void App::auto_play(int n, uint64_t seed) {
  std::mt19937_64 rng(seed);
  auto pick = [&](size_t k) { return static_cast<size_t>(rng() % k); };
  for (int i = 0, fails = 0; i < n && game_.request() && fails < 50; ++i) {
    const Request r = *game_.request();
    std::vector<uint32_t> res;
    if (r.type == WX_REQ_YES_NO) {
      res.push_back(static_cast<uint32_t>(pick(2)));
    } else if (r.type == WX_REQ_SELECT_CARDS) {
      std::vector<uint32_t> all;
      for (const auto& o : r.options) all.push_back(o.handle);
      std::shuffle(all.begin(), all.end(), rng);
      const size_t hi = std::min<size_t>(r.max, all.size());
      const size_t k = r.min + (hi > r.min ? pick(hi - r.min + 1) : 0);
      res.assign(all.begin(), all.begin() + std::min(k, all.size()));
    } else if (!r.options.empty()) {
      // 행동 선택: 끝내기는 가끔만
      size_t k = pick(r.options.size());
      if (r.type == WX_REQ_SELECT_ACTION && r.options[k].kind == WX_ACT_END && r.options.size() > 1 && pick(4)) k = pick(r.options.size());
      res.push_back(r.options[k].value);
    }
    if (game_.respond(res)) {
      fails = 0;
    } else if (++fails % 10 == 0 && r.cancelable) {
      game_.cancel();
    }
  }
  viewer_ = game_.request() ? game_.request()->player : 0;
  picks_.clear();
}

void App::draw_pass(ImVec2 size) {
  ImGui::SetNextWindowPos(ImVec2(size.x * 0.5f, size.y * 0.5f), ImGuiCond_Always, ImVec2(0.5f, 0.5f));
  ImGui::Begin("넘기기", nullptr, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoCollapse);
  ImGui::Text("P%d에게 넘기세요", pass_to_ + 1);
  if (ImGui::Button("확인", ImVec2(200, 40))) {
    viewer_ = pass_to_;
    pass_to_ = -1;
  }
  ImGui::End();
}

bool App::selectable(uint32_t handle) const {
  const auto& r = game_.request();
  if (!r || r->player != viewer_ || r->type != WX_REQ_SELECT_CARDS) return false;
  return std::any_of(r->options.begin(), r->options.end(), [&](const ReqOption& o) { return o.handle == handle; });
}

std::string App::action_label(const ReqOption& o) {
  std::string card = o.handle ? game_.card_label(viewer_, o.handle) : "";
  switch (o.kind) {
    case WX_ACT_END: return "끝내기";
    case WX_ACT_PLAY_SIGNI: {
      std::string z = o.zone < game_.zones().size() ? zone_label(game_.zones()[o.zone].name) : "";
      return "시그니 내기: " + card + " -> " + z;
    }
    case WX_ACT_REMOVE: return "리무브";
    case WX_ACT_USE: return "사용: " + card;
    case WX_ACT_ABILITY: return "【起】: " + card;
    case WX_ACT_GROW: return "그로우: " + card;
    case WX_ACT_KEY: return "키: " + card;
    default: return "?";
  }
}

// 요청 창. 장에서 바로 고를 수 있는 것(카드·존·행동)은 장에서 고르고,
// 여기에는 안내와 장에 안 보이는 카드(덱 속·아래 카드 등), 예/아니오·모드·숫자, 확정·취소를 둔다
void App::draw_request() {
  const auto& req = game_.request();
  if (!req) {
    ImGui::TextUnformatted(game_.ended() ? "대전이 끝났다" : "진행 중");
    return;
  }
  const Request r = *req;  // 응답하면 요청이 바뀌므로 복사해 둔다
  const float big = ImGui::GetFrameHeight() * 1.6f;
  ImGui::PushStyleColor(ImGuiCol_Text, r.player == viewer_ ? ImVec4(0.55f, 0.8f, 1.0f, 1) : ImVec4(1.0f, 0.6f, 0.5f, 1));
  ImGui::Text("P%d: %s", r.player + 1, hint_name(r.hint));
  ImGui::PopStyleColor();
  if (r.player != viewer_) {
    ImGui::TextDisabled("상대가 고르는 중");
    return;
  }
  const std::string& retry = game_.retry(viewer_);
  if (!retry.empty()) ImGui::TextColored(ImVec4(1, 0.5f, 0.4f, 1), "다시: %s", retry.c_str());
  ImGui::Separator();

  switch (r.type) {
    case WX_REQ_YES_NO:
      if (ImGui::Button("예", ImVec2(ImGui::GetContentRegionAvail().x * 0.5f - 4, big))) game_.respond({1});
      ImGui::SameLine();
      if (ImGui::Button("아니오", ImVec2(-1, big))) game_.respond({0});
      break;
    case WX_REQ_SELECT_ACTION: {
      ImGui::TextWrapped("초록색으로 빛나는 카드를 눌러 행동을 고른다. 루리그 덱 등 더미가 빛나면 눌러서 펼친다.");
      wx_game_info g{};
      wx_query_game(game_.duel(), &g);
      // 카드 없는 행동(끝내기·리무브)은 버튼으로
      for (const auto& o : r.options) {
        if (o.handle) continue;
        std::string label = o.kind == WX_ACT_END ? std::string(phase_name(g.phase)) + " 끝내기" : action_label(o);
        label += "##a" + std::to_string(o.value);
        if (ImGui::Button(label.c_str(), ImVec2(-1, big))) {
          picks_.clear();
          game_.respond({o.value});
          break;
        }
      }
      if (game_.request() && ImGui::CollapsingHeader("행동 목록 전체")) {
        for (const auto& o : r.options) {
          const std::string label = action_label(o) + "##l" + std::to_string(o.value);
          if (ImGui::Selectable(label.c_str())) {
            picks_.clear();
            game_.respond({o.value});
            break;
          }
          if (o.handle && ImGui::IsItemHovered()) {
            const wx_card_info c = game_.card(viewer_, o.handle);
            if (c.known) preview_cid_ = c.cid;
          }
        }
      }
      break;
    }
    case WX_REQ_SELECT_OPTION:
      if (r.hint == WX_HINT_ZONE) ImGui::TextWrapped("노랗게 빛나는 칸을 눌러도 된다.");
      for (const auto& o : r.options) {
        std::string label;
        if (r.hint == WX_HINT_ZONE && o.value < game_.zones().size())
          label = "P" + std::to_string(game_.zones()[o.value].owner + 1) + " " + zone_label(game_.zones()[o.value].name);
        else if (r.hint == WX_HINT_DECLARE)
          label = std::to_string(o.value);
        else if (r.hint == WX_HINT_MODE)
          label = "모드 " + std::to_string(o.value + 1);
        else
          label = std::to_string(o.value + 1) + "번째";
        label += "##o" + std::to_string(o.value);
        if (ImGui::Button(label.c_str(), ImVec2(-1, 0))) {
          game_.respond({o.value});
          break;
        }
      }
      break;
    case WX_REQ_SELECT_CARDS: {
      if (r.min == r.max)
        ImGui::Text("%u장 고르기", r.min);
      else
        ImGui::Text("%u ~ %u장 고르기", r.min, r.max);
      ImGui::TextDisabled("파랗게 빛나는 카드를 누른다");
      // 장에 안 보이는 후보(덱 속·트래시·아래 카드 등)는 여기에 그림으로
      std::vector<uint32_t> hidden;
      for (const auto& o : r.options)
        if (!shown_on_field(o.handle)) hidden.push_back(o.handle);
      if (!hidden.empty()) {
        ImGui::BeginChild("cands", ImVec2(0, std::min(ImGui::GetContentRegionAvail().y * 0.6f, 420.0f)), ImGuiChildFlags_Borders);
        draw_thumbs(hidden, 80.0f);
        ImGui::EndChild();
      }
      // 고른 순서
      for (size_t i = 0; i < picks_.size(); ++i) ImGui::Text("%zu. %s", i + 1, game_.card_label(viewer_, picks_[i]).c_str());
      const bool ok = picks_.size() >= r.min && picks_.size() <= r.max;
      ImGui::BeginDisabled(!ok);
      if (ImGui::Button(picks_.empty() ? "고르지 않고 진행" : "확정", ImVec2(ImGui::GetContentRegionAvail().x * 0.6f, big))) {
        const auto picks = picks_;
        picks_.clear();
        game_.respond(picks);
      }
      ImGui::EndDisabled();
      ImGui::SameLine();
      if (ImGui::Button("지우기", ImVec2(-1, big))) picks_.clear();
      break;
    }
  }
  if (r.cancelable) {
    ImGui::Separator();
    if (ImGui::Button("취소(처음으로)", ImVec2(-1, 0))) {
      picks_.clear();
      game_.cancel();
    }
  }
}

void App::draw_log() {
  const auto& log = game_.log(viewer_);
  ImGui::BeginChild("lines");
  for (const auto& line : log) ImGui::TextUnformatted(line.c_str());
  for (const auto& line : game_.log(WX_VIEW_ALL))
    if (line.rfind("[코어]", 0) == 0) ImGui::TextColored(ImVec4(1, 0.4f, 0.4f, 1), "%s", line.c_str());
  if (log.size() != last_log_size_) {
    ImGui::SetScrollHereY(1.0f);
    last_log_size_ = log.size();
  }
  ImGui::EndChild();
}

void App::draw_info_panel(ImVec2 pos, ImVec2 size) {
  ImGui::SetNextWindowPos(pos);
  ImGui::SetNextWindowSize(size);
  ImGui::Begin("정보", nullptr,
               ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoCollapse |
                   ImGuiWindowFlags_NoTitleBar);
  // 카드 그림: 패널 폭에 맞추되 높이는 패널의 절반까지
  const float avail = ImGui::GetContentRegionAvail().x;
  const Texture& t = preview_cid_ ? tex_.card(preview_cid_) : Texture{};
  const float ratio = t.id ? static_cast<float>(t.h) / t.w : 88.0f / 63.0f;
  float w = avail, h = avail * ratio;
  if (h > size.y * 0.5f) {
    h = size.y * 0.5f;
    w = h / ratio;
  }
  ImGui::SetCursorPosX(ImGui::GetCursorPosX() + (avail - w) * 0.5f);
  if (t.id) {
    ImGui::Image(t.id, ImVec2(w, h));
  } else {
    const ImVec2 p = ImGui::GetCursorScreenPos();
    ImGui::GetWindowDrawList()->AddRectFilled(p, ImVec2(p.x + w, p.y + h), IM_COL32(40, 44, 56, 255), 8.0f);
    ImGui::Dummy(ImVec2(w, h));
  }
  if (ImGui::BeginTabBar("tabs")) {
    if (ImGui::BeginTabItem("카드 정보")) {
      draw_card_info();
      ImGui::EndTabItem();
    }
    if (ImGui::BeginTabItem("로그")) {
      draw_log();
      ImGui::EndTabItem();
    }
    if (ImGui::BeginTabItem("설정")) {
      draw_settings();
      ImGui::EndTabItem();
    }
    ImGui::EndTabBar();
  }
  ImGui::End();
}

void App::draw_card_info() {
  if (!preview_cid_) {
    ImGui::TextDisabled("카드에 마우스를 올리면 여기에 나온다");
    return;
  }
  ImGui::BeginChild("info");
  const auto t = game_.db().text_of(preview_cid_);
  wx::CardData d;
  game_.db().read(preview_cid_, d);
  ImGui::PushTextWrapPos(0.0f);
  ImGui::TextUnformatted(t.name.c_str());
  std::string line;
  if (d.type & wx::TYPE_SIGNI) line = "Lv" + std::to_string(d.level) + "  파워 " + std::to_string(d.power);
  else if (d.type & (wx::TYPE_LRIG | wx::TYPE_ASSIST_LRIG))
    line = "Lv" + std::to_string(d.level) + "  리미트 " + std::to_string(d.limit);
  for (const auto& c : d.classes) line += (line.empty() ? "" : "  ") + std::string("<") + c + ">";
  if (!line.empty()) ImGui::TextDisabled("%s", line.c_str());
  if (!d.cost_ena.empty()) ImGui::TextDisabled("코스트 %s", d.cost_ena.c_str());
  if (!d.grow_ena.empty()) ImGui::TextDisabled("그로우 %s", d.grow_ena.c_str());
  ImGui::TextDisabled("[%u]", preview_cid_);
  if (preview_handle_) {
    const wx_card_info c = game_.card(viewer_, preview_handle_);
    if (c.known && c.cid == preview_cid_) {
      std::string now = power_text(c) + " " + state_text(c);
      if (c.zone < game_.zones().size()) now += "  [" + zone_label(game_.zones()[c.zone].name) + "]";
      ImGui::TextColored(ImVec4(0.55f, 0.8f, 1.0f, 1), "지금: %s", now.c_str());
    }
  }
  if (!t.ability.empty()) {
    ImGui::Separator();
    ImGui::TextUnformatted(t.ability.c_str());
  }
  if (!t.life_burst.empty()) {
    ImGui::Separator();
    ImGui::Text("LB: %s", t.life_burst.c_str());
  }
  ImGui::PopTextWrapPos();
  ImGui::EndChild();
}

void App::draw_settings() {
  ImGui::Text("시점: P%d", viewer_ + 1);
  if (ImGui::Button("시점 바꾸기")) {
    viewer_ = 1 - viewer_;
    picks_.clear();
    open_zone_ = -1;
  }
  ImGui::Checkbox("요청 따라가기", &follow_);
  ImGui::Checkbox("시점이 바뀔 때 넘기는 화면", &pass_screen_);
}

}  // namespace wxframe
