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
  void draw_request();
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
  void toggle_pick(uint32_t handle);
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
  int viewer_ = 0;
  int pass_to_ = -1;
  std::vector<uint32_t> picks_;  // 고른 순서대로
  std::string error_;
  size_t last_log_size_ = 0;
  uint32_t preview_cid_ = 0;     // 마지막으로 마우스를 올린 카드
  uint32_t preview_handle_ = 0;  // 그 카드가 장에 있으면 지금 값을 같이 보여 준다
  int open_zone_ = -1;           // 펼쳐 보는 더미(트래시 등)
};

}  // namespace wxframe
