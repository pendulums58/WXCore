#pragma once
#include <imgui.h>

#include <string>
#include <vector>

#include "game.h"
#include "textures.h"

namespace wxframe {

class App {
 public:
  explicit App(Textures& tex);
  void draw();
  // 시작 화면을 건너뛰고 지금 고른 덱으로 바로 시작(wx_frame --start)
  void quick_start();
  // 확인용: 무작위 응답을 n번 넣는다(wx_frame --auto n)
  void auto_play(int n, uint64_t seed);
  void set_preview(uint32_t cid) {
    preview_cid_ = cid;
    preview_handle_ = 0;
  }

 private:
  void draw_setup(ImVec2 size);
  void draw_pass(ImVec2 size);
  // 요청: 가운데 줄에 안내와 확정·끝내기 버튼, 장에서 못 고르는 것은 가운데 팝업
  void draw_bar_request(ImVec2 a, ImVec2 b);
  void draw_prompt();
  bool picks_ok() const;  // 지금 고른 카드로 확정할 수 있는가
  void confirm_picks();
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
  void draw_action_menu();
  void toggle_pick(uint32_t handle);
  // 지금 행동 요청에서 이 카드로 할 수 있는 행동
  std::vector<ReqOption> card_actions(uint32_t handle) const;
  // 존 선택 요청에서 이 존을 고를 수 있으면 응답 값, 아니면 -1
  int zone_choice(int zone) const;
  // 장 화면에서 바로 보이는 카드인가(아니면 요청 창에 그림으로 늘어놓는다)
  bool shown_on_field(uint32_t handle);
  void draw_thumbs(const std::vector<uint32_t>& cards, float w);
  bool selectable(uint32_t handle) const;
  std::string action_label(const ReqOption& o);

  Textures& tex_;
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
  uint32_t preview_handle_ = 0;  // 그 카드가 장에 있으면 지금 값을 같이 보여 준다
  int open_zone_ = -1;           // 펼쳐 보는 더미(트래시 등)
  uint32_t menu_handle_ = 0;     // 행동 메뉴를 띄운 카드
  ImVec2 menu_pos_;
  int menu_frame_ = 0;
  ImVec2 field_center_;  // 가운데 팝업을 처음 띄울 자리
};

}  // namespace wxframe
