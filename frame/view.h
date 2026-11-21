#pragma once
#include <imgui.h>

#include <string>
#include <vector>

#include "game.h"

namespace wxframe {

class App {
 public:
  App();
  void draw();
  // 시작 화면을 건너뛰고 지금 고른 덱으로 바로 시작(wx_frame --start)
  void quick_start();

 private:
  void draw_setup(ImVec2 size);
  void draw_pass(ImVec2 size);
  void draw_toolbar();
  void draw_side(int p, bool opponent);
  void draw_request();
  void draw_log();
  void card_button(uint32_t handle, float width);
  void zone_slot(int owner, const char* name, float width);
  void zone_list(int owner, const char* name, bool open_default);
  bool selectable(uint32_t handle) const;
  std::string action_label(const ReqOption& o);

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
};

}  // namespace wxframe
