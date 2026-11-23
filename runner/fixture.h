#pragma once
// 효과 케이스용 픽스처. 카드 데이터와 스크립트를 메모리에서 넘긴다.
#include <algorithm>
#include <cstdio>
#include <map>
#include <memory>
#include <string>
#include <vector>

#include "card_db.h"
#include "session.h"

namespace wxtest {

struct Fixture {
  std::map<wx::Cid, wx::CardData> cards;
  std::map<std::string, std::string> scripts;
  std::vector<std::string> logs;
  std::unique_ptr<wx::Session> session;  // 상태를 바꾸는 입력은 전부 session을 거친다(되돌리기용 기록)
  wx::Duel& d() { return session->duel(); }

  void signi(wx::Cid cid, int32_t power, uint8_t color = wx::COLOR_WHITE, int32_t level = 1,
             std::vector<uint32_t> classes = {}) {
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

  // 실제 카드 DB(케이스 사이에 공유). 켜면 cards·scripts에 없는 카드는 DB·스크립트 파일에서 읽는다
  bool use_db = false;
  static CardDb& db() {
    static CardDb d;
    if (!d.is_open()) d.open(data_dir() + "/wixoss.db");
    return d;
  }

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
      if (it != cards.end()) {
        out = it->second;
        return true;
      }
      return use_db && db().read(cid, out);
    };
    cfg.script = [this](const std::string& name, std::string& out) {
      auto it = scripts.find(name);
      if (it != scripts.end()) {
        out = it->second;
        return true;
      }
      if (name == "classes.lua") return db().read_script(name, out);  // 상수는 DB 없는 케이스에서도
      return use_db && read_script_file(name, out);
    };
    cfg.log = [this](const std::string& m) {
      logs.push_back(m);
      std::printf("    [log] %s\n", m.c_str());
    };
    session = std::make_unique<wx::Session>(std::move(cfg));
    return d();
  }

  wx::ZoneId zone(wx::PlayerId p, const char* name) { return d().state.zones.find(p, name); }
  size_t count(wx::PlayerId p, const char* name) { return d().state.zones.get(zone(p, name)).cards.size(); }
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
      const auto& acts = d().actions();
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
      if (d().process() == wx::Duel::Result::End) return false;
      const wx::Request* r = d().request();
      if (!r) continue;
      if (r->hint == hint) return true;
      seen.push_back(r->hint);
      session->respond(pass(*r));
    }
    return false;
  }

  bool saw(uint32_t hint) const { return std::find(seen.begin(), seen.end(), hint) != seen.end(); }

  bool answer(std::vector<uint32_t> picks) { return session->respond(wx::Response{std::move(picks)}); }

  // nth: 조건에 맞는 것 중 몇 번째(0부터). 한 카드의 【起】이 여럿일 때
  uint32_t action(wx::ActionKind kind, wx::CardIdx c = wx::kNoCard, wx::ZoneId z = wx::kNoZone, uint32_t nth = 0) {
    const auto& acts = d().actions();
    for (uint32_t i = 0; i < acts.size(); ++i)
      if (acts[i].kind == kind && (c == wx::kNoCard || acts[i].card == c) && (z == wx::kNoZone || acts[i].zone == z))
        if (nth-- == 0) return i;
    return 0xFFFFFFFF;
  }

  wx::CardIdx put(wx::Cid cid, wx::PlayerId p, const char* zone_name) {
    const wx::ZoneId z = zone(p, zone_name);
    return session->command([=](wx::Duel& d) { return d.new_card(cid, p, z); });
  }

  // 효과 처리 결과로 생긴 지속 효과(스펠·아츠·능력이 만든 것)를 흉내 낸다.
  // single: 「～まで」 고정 대상. by = 그 효과를 쓴 플레이어
  wx::EffectId single(wx::CardIdx target, uint32_t code, int32_t value, wx::PlayerId by,
                      uint32_t reset = 0) {
    return session->command([=](wx::Duel& d) {
      wx::EffectId id = d.effects.create();
      wx::Effect& e = *d.effects.get(id);
      e.type = wx::EFFECT_TYPE_SINGLE;
      e.code = code;
      e.value = value;
      e.owner_player = by;
      e.reset = reset;
      d.register_effect(id, target);
      return id;
    });
  }

  wx::EffectId grant(wx::CardIdx target, uint32_t code, int32_t value, wx::PlayerId by) {
    return session->command([=](wx::Duel& d) {
      wx::EffectId id = d.effects.create();
      wx::Effect& e = *d.effects.get(id);
      e.type = wx::EFFECT_TYPE_SINGLE;
      e.code = code;
      e.value = value;
      e.owner_player = by;
      d.grant_effect(id, target);
      return id;
    });
  }

  // 「～の間」「このターン」 동적 대상. 플레이어에 등록
  wx::EffectId field(uint32_t code, int32_t value, wx::PlayerId by, uint32_t self_loc, uint32_t opp_loc,
                     uint32_t reset = 0) {
    return session->command([=](wx::Duel& d) {
      wx::EffectId id = d.effects.create();
      wx::Effect& e = *d.effects.get(id);
      e.type = wx::EFFECT_TYPE_FIELD;
      e.code = code;
      e.value = value;
      e.owner_player = by;
      e.target_self = self_loc;
      e.target_opp = opp_loc;
      e.reset = reset;
      d.register_player_effect(id, by);
      return id;
    });
  }
};

}  // namespace wxtest
