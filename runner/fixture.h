#pragma once
// 효과 케이스용 픽스처. 카드 데이터와 스크립트를 메모리에서 넘긴다.
#include <algorithm>
#include <cstdio>
#include <map>
#include <memory>
#include <string>
#include <vector>

#include "duel.h"

namespace wxtest {

struct Fixture {
  std::map<wx::Cid, wx::CardData> cards;
  std::map<std::string, std::string> scripts;
  std::vector<std::string> logs;
  std::unique_ptr<wx::Duel> duel;

  void signi(wx::Cid cid, int32_t power, uint8_t color = wx::COLOR_WHITE, int32_t level = 1,
             std::vector<std::string> classes = {}) {
    wx::CardData d;
    d.cid = cid;
    d.type = wx::TYPE_SIGNI;
    d.power = power;
    d.color = color;
    d.level = level;
    d.classes = std::move(classes);
    cards[cid] = d;
  }

  void lrig(wx::Cid cid, uint8_t color = wx::COLOR_WHITE, int32_t level = 3, int32_t limit = 6) {
    wx::CardData d;
    d.cid = cid;
    d.type = wx::TYPE_LRIG;
    d.color = color;
    d.level = level;
    d.limit = limit;
    cards[cid] = d;
  }

  void script(wx::Cid cid, std::string code) { scripts["c" + std::to_string(cid) + ".lua"] = std::move(code); }

  bool test_mode = true;
  bool always_ask = true;  // 메인 페이즈마다 멈추게 해서 케이스가 끝없이 돌지 않게 한다
  wx::PlayerId first = wx::kNoPlayer;

  wx::Duel& start(uint64_t seed = 1) {
    wx::DuelConfig cfg;
    cfg.seed = seed;
    cfg.test_mode = test_mode;
    cfg.always_ask = always_ask;
    cfg.first_player = first;
    cfg.card_data = [this](wx::Cid cid, wx::CardData& out) {
      auto it = cards.find(cid);
      if (it == cards.end()) return false;
      out = it->second;
      return true;
    };
    cfg.script = [this](const std::string& name, std::string& out) {
      auto it = scripts.find(name);
      if (it == scripts.end()) return false;
      out = it->second;
      return true;
    };
    cfg.log = [this](const std::string& m) {
      logs.push_back(m);
      std::printf("    [log] %s\n", m.c_str());
    };
    duel = std::make_unique<wx::Duel>(cfg);
    return *duel;
  }

  wx::ZoneId zone(wx::PlayerId p, const char* name) { return duel->state.zones.find(p, name); }
  size_t count(wx::PlayerId p, const char* name) { return duel->state.zones.get(zone(p, name)).cards.size(); }
  void fill(wx::Cid cid, wx::PlayerId p, const char* name, int n) {
    for (int i = 0; i < n; ++i) put(cid, p, name);
  }

  // ── 진행 ──
  std::vector<uint32_t> seen;  // until이 기본 응답으로 넘긴 요청 힌트

  // 기본 응답: 안 고를 수 있으면 안 고르고, 예/아니오는 아니오, 메인은 페이즈 종료
  wx::Response pass(const wx::Request& r) {
    wx::Response res;
    if (r.type == wx::ReqType::YesNo) {
      res.picks = {0};
    } else if (r.type == wx::ReqType::SelectAction) {
      const auto& acts = duel->actions();
      for (uint32_t i = 0; i < acts.size(); ++i)
        if (acts[i].kind == wx::ActionKind::EndPhase) res.picks = {i};
    } else {
      res.picks.assign(r.options.begin(), r.options.begin() + r.min);
    }
    return res;
  }

  // 그 힌트의 요청이 나올 때까지 진행한다. 대전이 끝나면 false
  bool until(uint32_t hint, int max_steps = 500) {
    for (int i = 0; i < max_steps; ++i) {
      if (duel->process() == wx::Duel::Result::End) return false;
      const wx::Request* r = duel->request();
      if (!r) continue;
      if (r->hint == hint) return true;
      seen.push_back(r->hint);
      duel->respond(pass(*r));
    }
    return false;
  }

  bool saw(uint32_t hint) const { return std::find(seen.begin(), seen.end(), hint) != seen.end(); }

  bool answer(std::vector<uint32_t> picks) { return duel->respond(wx::Response{std::move(picks)}); }

  uint32_t action(wx::ActionKind kind, wx::CardIdx c = wx::kNoCard, wx::ZoneId z = wx::kNoZone) {
    const auto& acts = duel->actions();
    for (uint32_t i = 0; i < acts.size(); ++i)
      if (acts[i].kind == kind && (c == wx::kNoCard || acts[i].card == c) && (z == wx::kNoZone || acts[i].zone == z))
        return i;
    return 0xFFFFFFFF;
  }

  wx::CardIdx put(wx::Cid cid, wx::PlayerId p, const char* zone_name) {
    return duel->new_card(cid, p, zone(p, zone_name));
  }

  // 효과 처리 결과로 생긴 지속 효과(스펠·아츠·능력이 만든 것)를 흉내 낸다.
  // single: 「～まで」 고정 대상. by = 그 효과를 쓴 플레이어
  wx::EffectId single(wx::CardIdx target, uint32_t code, int32_t value, wx::PlayerId by,
                      uint32_t reset = 0) {
    wx::EffectId id = duel->effects.create();
    wx::Effect& e = *duel->effects.get(id);
    e.type = wx::EFFECT_TYPE_SINGLE;
    e.code = code;
    e.value = value;
    e.owner_player = by;
    e.reset = reset;
    duel->register_effect(id, target);
    return id;
  }

  wx::EffectId grant(wx::CardIdx target, uint32_t code, int32_t value, wx::PlayerId by) {
    wx::EffectId id = duel->effects.create();
    wx::Effect& e = *duel->effects.get(id);
    e.type = wx::EFFECT_TYPE_SINGLE;
    e.code = code;
    e.value = value;
    e.owner_player = by;
    duel->grant_effect(id, target);
    return id;
  }

  // 「～の間」「このターン」 동적 대상. 플레이어에 등록
  wx::EffectId field(uint32_t code, int32_t value, wx::PlayerId by, uint32_t self_loc, uint32_t opp_loc,
                     uint32_t reset = 0) {
    wx::EffectId id = duel->effects.create();
    wx::Effect& e = *duel->effects.get(id);
    e.type = wx::EFFECT_TYPE_FIELD;
    e.code = code;
    e.value = value;
    e.owner_player = by;
    e.target_self = self_loc;
    e.target_opp = opp_loc;
    e.reset = reset;
    duel->register_player_effect(id, by);
    return id;
  }
};

}  // namespace wxtest
