#pragma once
// 장 모델(YGOPro의 ClientField에 해당). 한 뷰가 받은 메시지로 장을 재구성한다.
// 코어가 없는 게스트도 같은 모델로 그린다. 메시지만으로는 모르는 값(효과가 반영된 파워·레벨, 덱 속 순서 등)은
// 코어를 가진 쪽(방장)이 조회해 UPDATE 메시지로 보충한다(EDOPro의 MSG_UPDATE_DATA와 같은 역할).
#include <cstdint>
#include <map>
#include <string>
#include <vector>

#include "wx_api.h"

namespace wxframe {

// 프레임이 만드는 메시지(코어 메시지와 같은 틀: u32 크기 + u16 종류 + 본문). 코어 번호와 겹치지 않게 0x8000부터
constexpr uint16_t kMsgUpdate = 0x8001;

struct ZoneMeta {
  uint16_t id = 0;
  uint8_t owner = 0;
  std::string name;
};

class FieldModel {
 public:
  void reset();  // 존 정보까지 지운다(MSG_RESET 뒤 처음부터 다시 오는 메시지로 다시 만든다)
  // 메시지 하나(size 필드부터). 모르는 종류는 무시한다
  void apply(const uint8_t* m, size_t len);

  const std::vector<ZoneMeta>& zones() const { return zones_; }
  const wx_card_info* card(uint32_t handle) const;
  // 부여된 능력(「…を得る」). 인쇄 능력은 없다
  const std::vector<wx_granted_info>& granted(uint32_t handle) const;
  const std::vector<uint32_t>& zone(uint16_t z) const;
  // host의 붙은 카드(attached) 또는 아래 카드(놓인 순서대로)
  static constexpr uint32_t kAttachedFlag = 256, kSetFlag = 512, kSeedFlag = 1024;
  uint32_t trap(uint16_t z) const;  // 【トラップ】 handle. 없으면 0
  uint32_t seed(uint16_t z) const;  // 【シード】 handle. 없으면 0
  std::vector<uint32_t> hosted(uint32_t host, bool attached) const;
  // 존 표식 비트: 1 【ゲート】, 2 【ウィルス】
  uint8_t markers(uint16_t z) const { return z < markers_.size() ? markers_[z] : 0; }
  bool gate(uint16_t z) const { return markers(z) & 1; }
  bool virus(uint16_t z) const { return markers(z) & 2; }
  const wx_game_info& game() const { return game_; }
  const wx_player_info& player(int p) const { return players_[p & 1]; }
  // 그 플레이어가 이 대전에서 한 번이라도 쓴 시스템(쓰기 전에는 장에 칸·표시를 만들지 않는다)
  static constexpr uint8_t kUsedBeat = 1, kUsedSubscribers = 2;
  bool used(int p, uint8_t bit) const { return used_[p & 1] & bit; }

  // 방장 쪽: 코어를 조회해 모델과 다른 것만 담은 UPDATE 메시지를 만든다. 다른 게 없으면 빈 벡터.
  // zone_fixes에는 메시지만으로 재구성한 존 내용이 틀려 고친 존 번호가 들어간다(검사용)
  std::vector<uint8_t> make_update(wx_duel* duel, uint8_t view, std::vector<uint16_t>* zone_fixes = nullptr) const;

 private:
  void remove_handle(uint32_t h);
  void parse_update(const uint8_t* p, size_t n);
  void mark_used();

  std::vector<ZoneMeta> zones_;
  std::vector<std::vector<uint32_t>> zone_cards_;
  std::vector<uint8_t> markers_;
  std::map<uint32_t, wx_card_info> cards_;
  std::map<uint32_t, std::vector<wx_granted_info>> granted_;
  wx_game_info game_{};
  wx_player_info players_[2]{};
  uint8_t used_[2]{};
};

}  // namespace wxframe
