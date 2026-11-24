#pragma once
#include <imgui.h>

#include <map>
#include <string>
#include <vector>

#include <memory>

#include "game.h"
#include "icon_text.h"
#include "online.h"
#include "repo_manager.h"
#include "updater.h"
#include "textures.h"

namespace wxframe {

class App {
 public:
  explicit App(Textures& tex);
  void draw();
  // 시작 화면을 건너뛰고 지금 고른 덱으로 바로 시작(wx_frame --start)
  void quick_start();
  // 확인용: 무작위 응답을 n번 넣는다(wx_frame --auto n)
  void auto_play(int n, uint64_t seed, uint32_t until_hint = 0);
  // 확인용: 127.0.0.1에만 방을 열고 게스트가 준비되면 바로 시작 / 바로 접속(wx_frame --host-local, --join)
  void dev_host(int port);
  void dev_join(const std::string& ip, int port);
  // 저장소 받기를 시작한다(config/configs.json). 화면 확인용 실행에서는 부르지 않는다
  void start_repos();
  bool quit_requested() const { return quit_; }  // 업데이트 뒤 다시 시작
  void set_preview(uint32_t cid) {
    preview_cid_ = cid;
    preview_handle_ = 0;
  }

 private:
  // 대전 밖 화면: 메인 메뉴 → 혼자 하기 설정 / 덱 편집(deck_editor.cpp)
  enum class Screen { Menu, Solo, DeckEdit, Host, Join };
  void draw_menu(ImVec2 size);
  void draw_setup(ImVec2 size);
  void draw_deck_editor(ImVec2 size);
  // 온라인(lobby.cpp): 방 만들기·참가. 대전 중에도 프레임마다 poll
  void draw_host(ImVec2 size);
  void draw_join(ImVec2 size);
  void draw_room(ImVec2 size);  // 방 대기 화면(방장·게스트·관전 공통)
  void draw_chat(float height); // 채팅 기록 + 입력(대기실)
  // 대전 화면 아래 줄의 채팅 창(YGOPro·CyanPro처럼 늘 떠 있다). 채팅과 스크립트 오류를 같이 보여 준다
  void draw_chat_bar(ImVec2 pos, ImVec2 size);
  void sync_chat();              // 새 채팅 줄·코어 오류를 chat_view_에 옮긴다
  bool chat_input(float width);  // 입력 줄. 보내면 true. 보낸 뒤에도 입력 칸에 포커스를 둔다
  void poll_online();
  bool online() const;  // 방을 열었거나 방에 접속한 상태
  void leave_online();  // 방 닫기·나가기
  bool deck_combo(const char* id, int& index);
  void reload_deck_list();
  // 덱 편집(deck_editor.cpp)
  void ed_toolbar();
  void ed_deck_area();
  void ed_search_panel();
  void ed_load(int file);
  void ed_new();
  bool ed_save(const std::string& file_stem);
  void ed_add(wx::Cid cid, int print = 1);
  void ed_remove(bool lrig_side, size_t index);
  void ed_sort();
  void ed_refresh_results();
  void ed_card_grid(const char* id, std::vector<wx::Cid>& cards, bool lrig_side, int per_row);
  void ed_print_picker();  // 검색 결과 휠클릭: 그 카드의 판본 목록(누르면 그 판본으로 넣는다)
  void ed_print_strip();  // 카드 정보 패널: 고른 덱 카드의 판본 썸네일 줄(누르면 그 장의 판본이 바뀐다)
  void ed_fix_idx();      // 판본 목록 길이를 덱에 맞춘다
  void ed_validate();
  void draw_pass(ImVec2 size);
  // 요청: 가운데 줄에 안내와 확정·끝내기 버튼, 장에서 못 고르는 것은 가운데 팝업
  void draw_bar_request(ImVec2 a, ImVec2 b);
  void draw_prompt();
  bool picks_ok() const;  // 지금 고른 카드로 확정할 수 있는가
  void confirm_picks();
  // 우클릭·Esc: 한 단계 물러난다(확인 창 → 행동 메뉴 → 배치 → 더미 창 → 고른 카드). 게임은 진행하지 않는다
  void back_out();
  void draw_skip_confirm();
  void draw_log();
  void draw_info_panel(ImVec2 pos, ImVec2 size);
  void draw_card_info();
  void draw_settings();
  // 장(field.cpp)
  struct CardOpt {
    bool lrig_back = false;  // 뒷면이면 루리그 덱 뒷면
    bool rot = false;        // 다운이 아니어도 가로로(라이프 클로스)
    bool stats = false;      // 파워 표시(장의 시그니)
    float hit = 0;           // 겹쳐 놓은 카드는 보이는 부분(hit 길이)만 누를 수 있게
    ImVec2 dir{1, 0};        // 다음 카드가 놓이는 화면 방향. 보이는 부분은 그 반대쪽
    bool from_start = false; // 가운데가 아니라 span 시작점부터 늘어놓는다(에나)
  };
  void draw_field(ImVec2 pos, ImVec2 size);
  void draw_middle_bar(ImVec2 a, ImVec2 b);
  void draw_side(int p, ImVec2 mid, float s, float cw);
  void field_slot(int p, const char* name, ImVec2 c, float cw);
  void pile(int p, const char* name, ImVec2 c, float cw, bool lrig_back);
  void card_row(const std::vector<uint32_t>& cards, ImVec2 c, float span, float w, const CardOpt& opt);
  void zone_button(int p, const char* name, ImVec2 c);
  void card_widget(uint32_t handle, ImVec2 c, float w, const CardOpt& opt);
  void draw_card_face(const wx_card_info& c, ImVec2 ctr, float w, bool rot, bool lrig_back);
  void draw_zone_window();
  void draw_host_window();  // 붙은 카드·밑의 카드
  void draw_action_menu();
  void toggle_pick(uint32_t handle);
  void click_pick(uint32_t handle);  // 후보 카드를 눌렀다(더블클릭이면 확정)
  // 지금 행동 요청에서 이 카드로 할 수 있는 행동
  std::vector<ReqOption> card_actions(uint32_t handle) const;
  // 존 선택 요청에서 이 존을 고를 수 있으면 응답 값, 아니면 -1
  int zone_choice(int zone) const;
  // 장 화면에서 바로 보이는 카드인가(아니면 요청 창에 그림으로 늘어놓는다)
  bool shown_on_field(uint32_t handle);
  void draw_thumbs(const std::vector<uint32_t>& cards, float w);
  // 요청 창의 카드(선택지·요청의 출처): 그림만, 누르면 true. 마우스를 올리면 왼쪽에 전문
  bool option_card(uint32_t handle, float w);
  void source_label(uint32_t handle);  // 「카드 이름」 글자. 마우스를 올리면 왼쪽에 전문
  // 아이콘 토큰을 그림으로 바꿔 width 폭에서 줄바꿈해 그린다. draw가 거짓이면 크기만 잰다
  ImVec2 rich_text_at(ImDrawList* dl, ImVec2 pos, const std::string& text, float width, ImU32 col, bool draw = true);
  // 지금 커서 자리에 그리고 커서를 넘긴다. width <= 0이면 남은 폭
  void rich_text(const std::string& text, float width = 0, ImU32 col = 0);
  // 효과 설명 문장(없으면 아무것도 안 그린다). width 폭에서 줄바꿈
  void desc_text(uint32_t desc, float width);
  // 연출(field.cpp): 선공 코인토스, 발동한 카드 그림, 장의 발동 카드 반짝임
  void update_fx();
  void draw_fx();
  bool selectable(uint32_t handle) const;
  std::string action_label(const ReqOption& o);

  Textures& tex_;
  IconMap icons_;  // 카드 텍스트의 아이콘 토큰 → 그림(데이터 폴더의 icons/icons.json)
  Screen screen_ = Screen::Menu;
  wxtest::CardDb db_;
  Game game_;
  std::vector<std::string> decks_;
  int deck_[2] = {0, 0};
  uint64_t seed_ = 1;
  bool practice_ = true;
  bool pass_screen_ = true;
  bool follow_ = true;
  bool auto_confirm_ = true;  // 장 수가 정해진 선택은 다 고르면 바로 확정
  int viewer_ = 0;
  int pass_to_ = -1;
  std::vector<uint32_t> picks_;  // 고른 순서대로
  std::string error_;
  size_t last_log_size_ = 0;
  uint32_t preview_cid_ = 0;     // 마지막으로 마우스를 올린 카드
  // 미리보기 판본: preview_idx_cid_가 preview_cid_와 같을 때만 쓴다(덱 에디터). 아니면 기본 그림
  int preview_idx_ = 1;
  uint32_t preview_idx_cid_ = 0;
  uint32_t preview_handle_ = 0;  // 그 카드가 장에 있으면 지금 값을 같이 보여 준다
  bool skip_confirm_ = false;    // 그로우할 수 있는데 안 고르고 넘어가려 한다: 확인 창
  // 더블클릭: 같은 요청에서 첫 클릭으로 고른 카드를 한 번 더 누르면 확정한다
  uint32_t click_handle_ = 0, click_serial_ = 0;
  bool click_added_ = false;
  bool confirm_requested_ = false;
  bool prompt_collapsed_ = false;  // 선택 창을 접었다(장을 보려고). 새 요청이 오면 펼친다
  uint32_t prompt_serial_ = 0;
  bool prompt_needed_ = false;     // 이번 요청에 선택 창이 있다(가운데 줄의 펼치기 버튼)
  uint32_t open_host_ = 0;       // 붙은 카드·밑의 카드를 펼쳐 보는 카드
  bool host_focus_ = false;
  int open_zone_ = -1;           // 펼쳐 보는 더미(트래시 등)
  bool zone_focus_ = false;      // 더미를 눌렀다: 그 창을 맨 앞으로
  uint32_t menu_handle_ = 0;     // 행동 메뉴를 띄운 카드
  uint32_t place_handle_ = 0;    // 「배치」를 고른 시그니. 존을 누르면 낸다
  ImVec2 menu_pos_;
  int menu_frame_ = 0;
  ImVec2 field_center_;  // 가운데 팝업을 처음 띄울 자리
  ImVec2 field_min_, field_max_;  // 장 창의 화면 사각형(연출 위치)
  int fx_mode_ = 1;  // 발동한 카드 그림: 0 끔, 1 상대 것만, 2 전부. 장 카드의 반짝임은 늘 한다
  double coin_t0_ = -1;  // 코인토스 시작 시각(없으면 음수)
  int coin_first_ = -1;
  struct Flash {
    uint32_t cid = 0;
    int print = 1;
    int who = -1;
    double t0 = -1;
  };
  Flash flash_;
  std::map<uint32_t, double> glow_until_;  // 발동한 카드 handle → 반짝임이 끝나는 시각

  // 온라인
  std::unique_ptr<OnlineHost> host_;
  std::unique_ptr<OnlineGuest> guest_;
  char nick_[64] = "플레이어";
  char ip_[64] = "127.0.0.1";
  char room_name_[64] = "";
  char password_[64] = "";
  char chat_input_[256] = "";
  struct ChatEntry {
    std::string name, text;
    bool error = false;  // 코어·스크립트 오류
    int count = 1;       // 같은 오류가 연달아 나온 횟수(카드 장수만큼 반복되는 스크립트 오류)
  };
  std::vector<ChatEntry> chat_view_;
  uint64_t chat_seen_ = 0;     // 온라인 채팅에서 옮긴 줄 수(chat_count 기준)
  size_t error_seen_ = 0;      // 대전 로그에서 옮긴 오류 줄 수
  bool chat_refocus_ = false;  // 다음 프레임에 입력 칸에 포커스(보낸 뒤·Enter)
  bool join_spectate_ = false;
  std::unique_ptr<LanFinder> finder_;
  int port_ = kDefaultPort;
  int online_deck_ = 0;
  std::string online_error_;
  bool dev_auto_start_ = false;
  // 자동 업데이트
  RepoManager repos_;
  Updater updater_;
  bool quit_ = false;
  bool repos_applied_ = false;
  std::string update_url_, repo_notice_;
  // 방장 덱 검사 결과(덱을 바꿀 때만 다시 검사)
  int my_deck_cached_ = -1;
  wxtest::DeckFile my_deck_;
  bool my_deck_loaded_ = false;
  std::vector<std::string> my_deck_problems_;

  // 덱 편집 상태
  struct Editor {
    bool opened = false;  // 편집기를 한 번이라도 열었나(처음에만 첫 덱을 연다)
    int file = -1;  // decks_ 안의 번호(-1 = 새 덱, 아직 파일 없음)
    wxtest::DeckFile deck;
    bool dirty = false;
    char name[128] = "";
    char save_as[128] = "";
    std::string message;
    std::vector<std::string> problems;  // 덱 검증 결과
    // 검색
    char query[128] = "";
    int type = 0;     // kTypeFilters 번호
    int colors = 0;   // 색 비트(0 = 전부)
    int level = -1;   // -1 = 전부
    bool pool = true; // 덱 포맷에서 쓸 수 있는 카드만
    std::vector<wx::Cid> results;
    bool results_dirty = true;
    int pending_file = -2;  // 저장 안 한 변경이 있을 때 넘어가려는 덱(-2 = 없음)
    uint32_t start_menu = 0;  // 시작 루리그 메뉴를 띄운 카드
    int sel = -1;             // 판본을 고를 덱 카드(자리). -1 = 없음
    bool sel_lrig = false;    // sel이 루리그 덱 자리인가
    wx::Cid pick_cid = 0;     // 판본 목록 팝업을 띄운 검색 결과 카드
  } ed_;
};

}  // namespace wxframe
