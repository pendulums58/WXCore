// 화면. 한 PC에서 두 사람이 번갈아 하는 핫시트. 요청을 받은 플레이어의 시점으로 그린다.
#include "view.h"

#include "core_loader.h"

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
  db_.open_all();  // 최상단·repositories/*·expansions/의 *.db(뒤가 우선)
  icons_.load(wxtest::data_dirs());
  reload_deck_list();
  if (decks_.size() > 1) deck_[1] = 1;
}

void App::start_repos() {
  std::vector<RepoConfig> repos;
  std::string err;
  if (!load_repo_config(wxtest::data_dir() + "/config/configs.json", repos, update_url_, err)) {
    repo_notice_ = err;
    return;
  }
  repos_.start(std::move(repos));
  if (!update_url_.empty()) updater_.check(update_url_, WX_CLIENT_VERSION);
}

void App::reload_deck_list() {
  decks_.clear();
  std::error_code ec;
  for (const auto& e : std::filesystem::directory_iterator(wxtest::data_dir() + "/decks", ec))
    if (e.path().extension() == ".json") decks_.push_back(e.path().stem().string());
  std::sort(decks_.begin(), decks_.end());
  for (int& d : deck_) d = std::min(d, std::max(0, static_cast<int>(decks_.size()) - 1));
}

void App::draw_menu(ImVec2 size) {
  ImGui::SetNextWindowPos(ImVec2(size.x * 0.5f, size.y * 0.5f), ImGuiCond_Always, ImVec2(0.5f, 0.5f));
  ImGui::Begin("WIXOSS 시뮬레이터", nullptr,
               ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoMove);
  const ImVec2 b(280, ImGui::GetFrameHeight() * 1.8f);
  if (!db_.is_open()) {
    ImGui::TextColored(ImVec4(1, 0.4f, 0.4f, 1), "카드 DB를 못 열었음: %s", db_.error().c_str());
    ImGui::TextUnformatted("python tools/build_db.py 로 먼저 만든다");
  }
  {
    const CoreInfo& ci = core_info();
    ImGui::TextDisabled("클라이언트 %s   코어 %u.%u (%s)", WX_CLIENT_VERSION, ci.major, ci.minor, ci.from_repo ? "저장소" : "동봉");
    // 클라이언트 업데이트
    switch (updater_.state()) {
      case Updater::Available:
        ImGui::TextColored(ImVec4(0.55f, 0.8f, 1.0f, 1), "%s", updater_.message().c_str());
        ImGui::SameLine();
        if (ImGui::SmallButton("업데이트")) updater_.apply(wxtest::data_dir());
        break;
      case Updater::Downloading:
        ImGui::TextDisabled("%s %d%%", updater_.message().c_str(), updater_.percent());
        break;
      case Updater::Ready:
        ImGui::TextColored(ImVec4(0.5f, 0.9f, 0.5f, 1), "%s", updater_.message().c_str());
        ImGui::SameLine();
        if (ImGui::SmallButton("다시 시작") && Updater::restart_self()) quit_ = true;
        break;
      case Updater::Failed: ImGui::TextColored(ImVec4(1, 0.5f, 0.4f, 1), "업데이트 확인: %s", updater_.message().c_str()); break;
      default: break;
    }
    if (!ci.skipped.empty()) ImGui::TextColored(ImVec4(1, 0.8f, 0.3f, 1), "저장소 코어가 이 클라이언트와 버전이 달라 동봉 코어를 쓴다(클라이언트 업데이트 필요)");
  }
  // 저장소(자동 업데이트)
  if (ImGui::CollapsingHeader("저장소", repos_.running() ? ImGuiTreeNodeFlags_DefaultOpen : 0)) {
    for (const auto& s : repos_.status()) {
      const ImVec4 col = s.state == RepoStatus::Failed ? ImVec4(1, 0.5f, 0.4f, 1)
                         : s.state == RepoStatus::Done ? ImVec4(0.5f, 0.9f, 0.5f, 1)
                                                       : ImVec4(0.8f, 0.8f, 0.8f, 1);
      if (s.state == RepoStatus::Working)
        ImGui::TextColored(col, "%s: %s %d%%", s.name.c_str(), s.message.c_str(), s.percent);
      else
        ImGui::TextColored(col, "%s: %s", s.name.c_str(), s.message.c_str());
    }
    if (repos_.status().empty()) ImGui::TextDisabled("받을 저장소가 없다(config/configs.json)");
  }
  if (!repo_notice_.empty()) ImGui::TextColored(ImVec4(1, 0.8f, 0.3f, 1), "%s", repo_notice_.c_str());
  if (ImGui::Button("혼자 하기(한 PC에서 둘이)", b)) {
    reload_deck_list();
    screen_ = Screen::Solo;
  }
  if (ImGui::Button("덱 편집", b)) screen_ = Screen::DeckEdit;
  if (ImGui::Button("방 만들기", b)) {
    reload_deck_list();
    my_deck_cached_ = -1;
    screen_ = Screen::Host;
  }
  if (ImGui::Button("참가(IP로 접속)", b)) {
    reload_deck_list();
    screen_ = Screen::Join;
  }
  ImGui::End();
}

void App::draw() {
  const ImVec2 size = ImGui::GetIO().DisplaySize;
  poll_online();
  // 저장소를 다 받았으면 대전 밖에서 카드 DB를 다시 읽는다. 코어는 다시 시작해야 바뀐다
  if (repos_.finished() && !repos_applied_ && !game_.running()) {
    repos_applied_ = true;
    bool data = false, core = false;
    for (const auto& s : repos_.status()) {
      if (!s.changed) continue;
      (s.has_core ? core : data) = true;
    }
    if (data) {
      db_.close_all();
      db_.open_all();
      icons_.clear();
      icons_.load(wxtest::data_dirs());
      ed_.results_dirty = true;
      reload_deck_list();
    }
    if (core) repo_notice_ = "코어가 갱신됐다. 다시 시작하면 새 코어를 쓴다";
  }
  if (!game_.running()) {
    switch (screen_) {
      case Screen::Menu: draw_menu(size); break;
      case Screen::Solo: draw_setup(size); break;
      case Screen::DeckEdit: draw_deck_editor(size); break;
      case Screen::Host: draw_host(size); break;
      case Screen::Join: draw_join(size); break;
    }
    return;
  }
  // 게스트는 P2 자리에서 본다. 대전자는 시점을 바꾸지 않는다(상대 비공개 정보). 관전자는 공개 정보만 받으므로 바꿔도 된다
  if (game_.remote() && game_.seat() == 1 && viewer_ != 1) {
    viewer_ = 1;
    follow_ = false;
    pass_screen_ = false;
    pass_to_ = -1;
    picks_.clear();
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
  // 왼쪽: 카드 미리보기 + 탭, 나머지: 장(요청은 장 가운데 줄과 팝업)
  const float left_w = std::clamp(size.x * 0.22f, 240.0f, 420.0f);
  draw_info_panel(ImVec2(0, 0), ImVec2(left_w, size.y));
  draw_field(ImVec2(left_w, 0), ImVec2(size.x - left_w, size.y));
  draw_prompt();
  draw_skip_confirm();

  // 배치 중: 그 카드를 더 낼 수 없게 됐으면 그만둔다
  if (place_handle_) {
    const auto acts = card_actions(place_handle_);
    const bool can = std::any_of(acts.begin(), acts.end(), [](const ReqOption& o) { return o.kind == WX_ACT_PLAY_SIGNI; });
    if (!can) place_handle_ = 0;
  }
  // 우클릭·Esc는 물러나기만 한다. 확정·건너뛰기처럼 게임을 진행하는 일은 버튼으로만
  if (ImGui::IsMouseClicked(ImGuiMouseButton_Right) || ImGui::IsKeyPressed(ImGuiKey_Escape)) back_out();
  // 장 수가 정해진 선택은 다 고르면 바로 확정
  const auto& r = game_.request();
  if (auto_confirm_ && r && r->type == WX_REQ_SELECT_CARDS && r->min == r->max && r->max > 0 && picks_.size() == r->max &&
      picks_ok())
    confirm_picks();
}

bool App::picks_ok() const {
  const auto& r = game_.request();
  return r && r->player == viewer_ && r->type == WX_REQ_SELECT_CARDS && picks_.size() >= r->min && picks_.size() <= r->max;
}

void App::confirm_picks() {
  // 그로우할 수 있는데 안 고르고 넘어가면 한 번 더 묻는다(놓치면 되돌릴 수 없다)
  const auto& r = game_.request();
  if (picks_.empty() && !skip_confirm_ && r && r->type == WX_REQ_SELECT_CARDS && r->hint == WX_HINT_GROW &&
      !r->options.empty()) {
    skip_confirm_ = true;
    return;
  }
  skip_confirm_ = false;
  const auto picks = picks_;
  picks_.clear();
  game_.respond(picks);
}

void App::back_out() {
  if (skip_confirm_) {
    skip_confirm_ = false;
  } else if (menu_handle_) {
    menu_handle_ = 0;
  } else if (place_handle_) {
    place_handle_ = 0;
  } else if (open_zone_ >= 0) {
    open_zone_ = -1;
  } else {
    picks_.clear();
  }
}

void App::draw_skip_confirm() {
  const auto& r = game_.request();
  if (!r || r->player != viewer_ || r->hint != WX_HINT_GROW) skip_confirm_ = false;
  const char* id = "넘어가기 확인";
  if (skip_confirm_ && !ImGui::IsPopupOpen(id)) ImGui::OpenPopup(id);
  const ImVec2 ds = ImGui::GetIO().DisplaySize;
  ImGui::SetNextWindowPos(ImVec2(ds.x * 0.5f, ds.y * 0.5f), ImGuiCond_Appearing, ImVec2(0.5f, 0.5f));
  if (!ImGui::BeginPopupModal(id, nullptr, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoMove)) return;
  if (!skip_confirm_) {
    ImGui::CloseCurrentPopup();
  } else {
    const float big = ImGui::GetFrameHeight() * 1.5f;
    ImGui::TextUnformatted("그로우할 수 있는 루리그가 있다. 그로우하지 않고 넘어갈까?");
    if (ImGui::Button("돌아가기", ImVec2(160, big))) {
      skip_confirm_ = false;
      ImGui::CloseCurrentPopup();
    }
    ImGui::SameLine();
    if (ImGui::Button("그로우하지 않고 넘어가기", ImVec2(220, big))) {
      ImGui::CloseCurrentPopup();
      confirm_picks();  // skip_confirm_이 켜져 있으므로 다시 묻지 않는다
    }
    ImGui::TextDisabled("우클릭·Esc: 돌아가기");
  }
  ImGui::EndPopup();
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
  ImGui::SameLine();
  if (ImGui::Button("메뉴로")) screen_ = Screen::Menu;
  if (!error_.empty()) ImGui::TextColored(ImVec4(1, 0.4f, 0.4f, 1), "%s", error_.c_str());
  ImGui::End();
}

void App::quick_start() {
  screen_ = Screen::Solo;  // 대전이 끝나면 설정 화면으로 돌아온다
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

void App::auto_play(int n, uint64_t seed, uint32_t until_hint) {
  std::mt19937_64 rng(seed);
  auto pick = [&](size_t k) { return static_cast<size_t>(rng() % k); };
  for (int i = 0, fails = 0; i < n && game_.request() && fails < 50; ++i) {
    const Request r = *game_.request();
    if (until_hint && r.hint == until_hint) break;
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

// 가운데 팝업. 장에서 바로 고를 수 없을 때만 뜬다:
// 예/아니오, 모드·숫자·순서 고르기, 장에 안 보이는 후보 카드(루리그 덱·덱 속·트래시·아래 카드 등)
void App::draw_prompt() {
  const auto& req = game_.request();
  if (!req || req->player != viewer_) return;
  const Request r = *req;  // 응답하면 요청이 바뀌므로 복사해 둔다
  std::vector<uint32_t> hidden;
  if (r.type == WX_REQ_SELECT_CARDS)
    for (const auto& o : r.options)
      if (!shown_on_field(o.handle)) hidden.push_back(o.handle);
  // 존 고르기는 장의 칸을 누르면 되지만, 장에 없는 존(덱 등)도 있을 수 있어 같이 띄운다
  const bool need = r.type == WX_REQ_YES_NO || r.type == WX_REQ_SELECT_OPTION || !hidden.empty();
  if (!need) return;

  // 처음에는 가운데 줄 바로 위(상대 쪽)에 띄운다. 옮기면 그 자리를 기억한다
  ImGui::SetNextWindowPos(ImVec2(field_center_.x, field_center_.y - 30), ImGuiCond_FirstUseEver, ImVec2(0.5f, 1.0f));
  const std::string title = std::string(hint_name(r.hint)) + "###prompt";
  ImGui::PushStyleColor(ImGuiCol_WindowBg, IM_COL32(24, 28, 40, 255));
  ImGui::Begin(title.c_str(), nullptr, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoCollapse);
  ImGui::PopStyleColor();
  const float big = ImGui::GetFrameHeight() * 1.5f;
  const std::string& retry = game_.retry(viewer_);
  if (!retry.empty()) ImGui::TextColored(ImVec4(1, 0.5f, 0.4f, 1), "다시: %s", retry.c_str());
  // 무엇에 대한 요청인가: 작은 그림 + 이름
  if (r.source) {
    option_card(r.source, 48.0f);
    ImGui::SameLine();
    ImGui::BeginGroup();
    source_label(r.source);
    if (r.source_desc && !game_.db().desc_text(r.source_desc).empty())
      desc_text(r.source_desc, 360.0f);
    else
      ImGui::TextDisabled("마우스를 올리면 왼쪽에 전문");
    ImGui::EndGroup();
  }
  const bool option_cards =
      std::any_of(r.options.begin(), r.options.end(), [](const ReqOption& o) { return o.handle != 0; });

  switch (r.type) {
    case WX_REQ_YES_NO:
      if (ImGui::Button("예", ImVec2(140, big))) game_.respond({1});
      ImGui::SameLine();
      if (ImGui::Button("아니오", ImVec2(140, big))) game_.respond({0});
      break;
    case WX_REQ_SELECT_OPTION:
      // 선택지마다 카드가 있으면(동시 트리거 순서 등) 카드 그림을 누른다
      if (option_cards && r.type == WX_REQ_SELECT_OPTION) {
        if (r.hint == WX_HINT_TRIGGER_ORDER) ImGui::TextDisabled("먼저 처리할 능력을 누른다");
        const float w = 64.0f;
        for (size_t i = 0; i < r.options.size(); ++i) {
          const ReqOption& o = r.options[i];
          ImGui::PushID(static_cast<int>(i));
          bool pressed = o.handle ? option_card(o.handle, w) : ImGui::Button("?", ImVec2(w, w * 88.0f / 63.0f));
          ImGui::SameLine();
          ImGui::BeginGroup();
          if (o.handle) source_label(o.handle);
          desc_text(o.desc, 360.0f);
          pressed |= ImGui::Button("이 능력부터");
          ImGui::EndGroup();
          ImGui::PopID();
          if (pressed) {
            game_.respond({o.value});
            break;
          }
        }
        break;
      }
      if (r.hint == WX_HINT_ZONE) ImGui::TextDisabled("노랗게 빛나는 칸을 눌러도 된다");
      for (const auto& o : r.options) {
        std::string label;
        if (r.hint == WX_HINT_ZONE && o.value < game_.zones().size())
          label = "P" + std::to_string(game_.zones()[o.value].owner + 1) + " " + zone_label(game_.zones()[o.value].name);
        else if (r.hint == WX_HINT_DECLARE)
          label = std::to_string(o.value);
        else if (r.hint == WX_HINT_MODE && o.desc && !game_.db().desc_text(o.desc).empty())
          label = game_.db().desc_text(o.desc);
        else if (r.hint == WX_HINT_MODE)
          label = "모드 " + std::to_string(o.value + 1);
        else
          label = std::to_string(o.value + 1) + "번째";
        // 긴 문장(모드 설명)은 버튼 안에서 줄바꿈한다
        const float wrap = 400.0f, pad = ImGui::GetStyle().FramePadding.x;
        const std::string shown = label.substr(0, label.find("##"));
        const ImVec2 ts = rich_text_at(nullptr, ImVec2(0, 0), shown, wrap - pad * 2, 0, false);
        const bool wide = ts.x > 290 - pad * 2 || ts.y > ImGui::GetFontSize() * 1.5f;
        ImGui::PushID(static_cast<int>(o.value));
        bool pressed;
        if (wide) {
          const ImVec2 at = ImGui::GetCursorScreenPos();
          pressed = ImGui::Button("##o", ImVec2(wrap, ts.y + ImGui::GetStyle().FramePadding.y * 2));
          rich_text_at(ImGui::GetWindowDrawList(), ImVec2(at.x + pad, at.y + ImGui::GetStyle().FramePadding.y), shown,
                       wrap - pad * 2, ImGui::GetColorU32(ImGuiCol_Text));
        } else {
          pressed = ImGui::Button(label.c_str(), ImVec2(290, 0));
        }
        ImGui::PopID();
        if (pressed) {
          game_.respond({o.value});
          break;
        }
      }
      break;
    case WX_REQ_SELECT_CARDS: {
      if (r.min == r.max)
        ImGui::Text("%u장 고르기  (%zu/%u)", r.min, picks_.size(), r.max);
      else
        ImGui::Text("%u ~ %u장 고르기  (%zu)", r.min, r.max, picks_.size());
      // 후보 그림: 한 줄에 6장까지, 넘치면 스크롤
      const float w = 90.0f, pad = 8.0f;
      const int per_row = std::min<int>(6, static_cast<int>(hidden.size()));
      const int rows = (static_cast<int>(hidden.size()) + per_row - 1) / per_row;
      const ImVec2 wp = ImGui::GetStyle().WindowPadding;
      const float ch = std::min(rows, 2) * (w * 88.0f / 63.0f + pad) + wp.y * 2;
      const float cw = per_row * (w + pad) + wp.x * 2 + (rows > 2 ? ImGui::GetStyle().ScrollbarSize : 0);
      ImGui::BeginChild("cands", ImVec2(cw, ch), ImGuiChildFlags_Borders);
      draw_thumbs(hidden, w);
      ImGui::EndChild();
      ImGui::TextDisabled("카드를 눌러 고르고, 확정은 버튼으로");
      ImGui::BeginDisabled(!picks_ok());
      if (ImGui::Button(picks_.empty() && r.min == 0 ? "고르지 않고 진행" : "확정", ImVec2(160, big))) confirm_picks();
      ImGui::EndDisabled();
      ImGui::SameLine();
      if (ImGui::Button("지우기", ImVec2(80, big))) picks_.clear();
      break;
    }
  }
  if (r.cancelable) {
    ImGui::SameLine();
    if (ImGui::Button("취소", ImVec2(80, big))) {
      picks_.clear();
      game_.cancel();
    }
  }
  ImGui::End();
}

void App::draw_log() {
  const auto& log = game_.log(viewer_);
  const ImVec4 kMe(0.55f, 0.8f, 1.0f, 1), kOpp(1.0f, 0.6f, 0.5f, 1);
  auto who_text = [&](int who) { return who == viewer_ ? "나" : "상대"; };
  ImGui::BeginChild("lines");
  for (const auto& l : log) {
    ImGui::BeginGroup();
    switch (l.kind) {
      case LogLine::Turn:
        ImGui::Spacing();
        ImGui::PushStyleColor(ImGuiCol_Text, l.who == viewer_ ? kMe : kOpp);
        ImGui::SeparatorText((l.text + " · " + who_text(l.who)).c_str());
        ImGui::PopStyleColor();
        break;
      case LogLine::Phase: ImGui::TextDisabled("  %s", l.text.c_str()); break;
      case LogLine::System:
        if (l.who >= 0)
          ImGui::TextColored(ImVec4(1, 0.85f, 0.3f, 1), "%s: %s", l.text.c_str(), who_text(l.who));
        else
          ImGui::TextColored(ImVec4(1, 0.85f, 0.3f, 1), "%s", l.text.c_str());
        break;
      case LogLine::Error: ImGui::TextColored(ImVec4(1, 0.4f, 0.4f, 1), "%s", l.text.c_str()); break;
      case LogLine::Normal: {
        ImGui::TextColored(l.who == viewer_ ? kMe : kOpp, "%s", l.who < 0 ? "  " : who_text(l.who));
        ImGui::SameLine();
        std::string t = l.text;
        if (l.cid) t += ": " + game_.db().text_of(l.cid).name;
        if (l.count > 1) t += "  ×" + std::to_string(l.count);
        ImGui::PushTextWrapPos(0.0f);
        ImGui::TextUnformatted(t.c_str());
        if (const std::string d = l.desc ? game_.db().desc_text(l.desc) : std::string(); !d.empty())
          rich_text("  " + d, 0, ImGui::GetColorU32(ImGuiCol_TextDisabled));
        ImGui::PopTextWrapPos();
        break;
      }
    }
    ImGui::EndGroup();
    if (l.cid && ImGui::IsItemHovered()) preview_cid_ = l.cid;
  }
  for (const auto& l : game_.log(WX_VIEW_ALL))
    if (l.kind == LogLine::Error) ImGui::TextColored(ImVec4(1, 0.4f, 0.4f, 1), "%s", l.text.c_str());
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
                   ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoBringToFrontOnFocus);  // 배경 창(장과 같다)
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
    // 로그·대화·설정은 대전 중에만(대화는 온라인일 때)
    if (game_.running() && ImGui::BeginTabItem("로그")) {
      draw_log();
      ImGui::EndTabItem();
    }
    if (game_.running() && online() && ImGui::BeginTabItem("대화")) {
      draw_chat(ImGui::GetContentRegionAvail().y - ImGui::GetFrameHeightWithSpacing() - 4);
      ImGui::EndTabItem();
    }
    if (game_.running() && ImGui::BeginTabItem("설정")) {
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
    rich_text(t.ability);
  }
  if (!t.life_burst.empty()) {
    ImGui::Separator();
    rich_text("LB: " + t.life_burst);
  }
  ImGui::PopTextWrapPos();
  ImGui::EndChild();
}

void App::draw_settings() {
  ImGui::Text("시점: P%d", viewer_ + 1);
  const bool spectator = game_.remote() && game_.seat() == 2;
  if ((!online() || spectator) && ImGui::Button("시점 바꾸기")) {
    viewer_ = 1 - viewer_;
    picks_.clear();
    open_zone_ = -1;
  }
  if (!online()) ImGui::Checkbox("요청 따라가기", &follow_);
  ImGui::Checkbox("장 수가 정해진 선택은 다 고르면 바로 확정", &auto_confirm_);
  ImGui::TextDisabled("우클릭·Esc: 창 닫기·배치 취소·고른 카드 풀기(확정은 버튼으로만)");
  if (!online()) ImGui::Checkbox("시점이 바뀔 때 넘기는 화면", &pass_screen_);
}

}  // namespace wxframe
