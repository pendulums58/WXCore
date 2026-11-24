// 룰 처리 11종(용어집: ルール処理). 한 번 훑을 때 해당하는 것을 모두 처리하고,
// 하나라도 처리했으면 true를 돌려준다. resolve()가 false가 될 때까지 반복한다.
#include <algorithm>

#include "duel.h"
#include "wx_api.h"

namespace wx {

namespace {
Request pick_one(PlayerId p, uint32_t hint, const std::vector<CardIdx>& cands) {
  Request r;
  r.type = ReqType::SelectCards;
  r.player = p;
  r.hint = hint;
  r.options.assign(cands.begin(), cands.end());
  r.min = r.max = 1;
  return r;
}
}  // namespace

Task<bool> Duel::rule_processing() {
  bool any = false;
  const PlayerId order[2] = {turn_player, opponent(turn_player)};

  // 장의 시그니(시그니 존 + 치어 존)
  auto field_signi = [&](PlayerId p, bool include_cheer) {
    std::vector<CardIdx> out;
    for (ZoneId z : state.zones.in_group(p, ZG_FIELD)) {
      const ZoneKind k = state.zones.get(z).kind;
      if (k != ZoneKind::Signi && !(include_cheer && k == ZoneKind::Cheer)) continue;
      if (CardIdx c = occupant(z); c != kNoCard && state.cards.get(c).face_up) out.push_back(c);
    }
    return out;
  };
  auto zone_of = [&](CardIdx c, ZoneKind k) { return state.zones.find(state.cards.get(c).owner, k); };

  // 1. 파워 0 이하 → 바니시(동시)
  {
    std::vector<CardIdx> dead;
    for (PlayerId p : order)
      for (CardIdx c : field_signi(p, true))
        if ((type_of(c) & TYPE_SIGNI) && power_raw(c) <= 0) dead.push_back(c);
    // 대체(チャーム)를 먼저 다 정하고 나머지를 같이 바니시한다. 대체해도 파워가 그대로면 다음 룰 처리에서 바니시된다(WD22-020 FAQ)
    std::vector<CardIdx> gone;
    for (CardIdx c : dead) {
      if (co_await charm_guard(c, REASON_RULE)) any = true;
      else gone.push_back(c);
    }
    for (CardIdx c : gone) any |= banish(c, REASON_RULE, kNoPlayer);
  }

  // 2. 레벨·리미트 초과 → 1체씩 골라 트래시. 순서: A 레벨 초과 → B 레벨이 바뀐 시그니 → C 그 외
  //    치어 존 시그니는 레벨만 본다(용어집: チアゾーン 3)
  for (PlayerId p : order) {
    const CardIdx center = center_lrig(p);
    if (center == kNoCard) continue;
    for (;;) {
      const int32_t lv = level_of(center);
      std::vector<CardIdx> a, b, c;
      for (CardIdx s : field_signi(p, true))
        if (level_of(s) > lv) a.push_back(s);
      int32_t sum = 0;
      const auto zone_signi = field_signi(p, false);
      for (CardIdx s : zone_signi) sum += limit_cost_of(s);
      const bool over_limit = sum > total_limit(p);
      if (a.empty() && !over_limit) break;
      std::vector<CardIdx> cands = a;
      if (cands.empty()) {
        for (CardIdx s : zone_signi) {
          auto it = last_levels_.find(state.cards.get(s).oid);
          (it != last_levels_.end() && it->second != level_of(s) ? b : c).push_back(s);
        }
        cands = b.empty() ? c : b;
      }
      CardIdx pick = cands.front();
      if (cands.size() > 1) {
        Response r = co_await ask(pick_one(p, HINT_RULE_TRASH, cands));
        pick = r.picks[0];
      }
      move_card(pick, zone_of(pick, ZoneKind::Trash), REASON_RULE, kNoPlayer);
      any = true;
    }
  }

  // 3·11. 장을 떠난 시그니에 붙어 있던 카드·아래 카드 → 트래시, 【ソウル】(루리그) → 루리그 트래시
  for (ZoneId z = 0; z < state.zones.size(); ++z) {
    const auto left = state.zones.get(z).leftovers;
    for (CardIdx c : left) {
      const bool lrig = data(state.cards.get(c).cid).type & (TYPE_LRIG | TYPE_ASSIST_LRIG);
      move_card(c, zone_of(c, lrig ? ZoneKind::LrigTrash : ZoneKind::Trash), REASON_RULE, kNoPlayer);
      any = true;
    }
  }

  // 4. 크러시된 카드: 버스트 아이콘이 있으면 발동 여부를 고른다. 아니면 에나 존으로
  {
    const auto list = std::exchange(crushed_, {});
    for (CardIdx c : list) {
      const Card& card = state.cards.get(c);
      if (card.zone == kNoZone || state.zones.get(card.zone).kind != ZoneKind::Check) continue;
      bool burst = false;
      Effect* granted = data(card.cid).life_burst ? nullptr : player_effect(card.owner, EFFECT_GRANT_LIFEBURST);
      const EffectId proto = granted ? granted->label_effect : kNoEffect;
      if (data(card.cid).life_burst || proto) {
        Request r;
        r.type = ReqType::YesNo;
        r.player = card.owner;
        r.hint = HINT_LIFEBURST;
        r.options = {0, 1};
        r.source = c;
        r.source_desc = proto ? desc_of(proto) : lb_desc(c);
        Response res = co_await ask(std::move(r));
        burst = res.picks[0] == 1;
      }
      if (burst) {
        Pending t;
        t.handler = c;
        t.player = card.owner;
        t.burst_card = c;
        t.event.code = EVENT_CRUSHED;
        t.event.cards = {c};
        t.event.player = card.owner;
        effects.for_each([&](Effect& e) {
          if (e.handler == c && (e.type & EFFECT_TYPE_LIFEBURST) && t.effect == kNoEffect) t.effect = e.id;
        });
        if (proto) {  // 얻은 라이프 버스트: 원형을 그 카드의 능력으로 복제한다
          const Effect tmpl = *effects.get(proto);
          t.effect = effects.create();
          Effect& n = *effects.get(t.effect);
          n = tmpl;
          n.id = t.effect;
          n.handler = c;
          n.owner_player = card.owner;
        }
        pending_[card.owner].push_back(std::move(t));
        Event lb;
        lb.code = EVENT_LIFEBURST;
        lb.cards = {c};
        lb.player = card.owner;
        raise(lb);
      } else {
        crushed_to_ena(c);
      }
      any = true;
    }
  }

  // 5. 메인 덱 0장 → 리프레시(지연된 룰 처리). 턴 플레이어의 그 턴 2번째면 턴 종료(용어집: リフレッシュ)
  for (PlayerId p : order) {
    const ZoneId deck = state.zones.find(p, ZoneKind::MainDeck);
    const ZoneId trash = state.zones.find(p, ZoneKind::Trash);
    if (!state.zones.get(deck).cards.empty() || state.zones.get(trash).cards.empty()) continue;
    for (CardIdx c : std::vector<CardIdx>(state.zones.get(trash).cards)) state.move(c, deck);
    state.shuffle(deck);
    const ZoneId life = state.zones.find(p, ZoneKind::LifeCloth);
    if (CardIdx top = top_of(life); top != kNoCard) move_card(top, trash, REASON_RULE, kNoPlayer);
    ++players[p].refreshes_this_turn;
    msg_player(WX_MSG_REFRESH, p);
    Event ev;
    ev.code = EVENT_REFRESH;
    ev.player = p;
    raise(ev);
    if (p == turn_player && players[p].refreshes_this_turn == 2) end_turn_requested_ = true;
    any = true;
  }

  // 6. 레조나가 루리그 덱·루리그 트래시·시그니 존·치어 존 밖 → 루리그 덱
  // 7. 루리그·키가 루리그 덱·루리그 트래시·루리그 존·시그니 존·치어 존 밖 → 루리그 트래시
  //    둘 다 「표기상」 종류를 본다(용어집: レゾナ 5)
  for (CardIdx c = 0; c < state.cards.size(); ++c) {
    const Card& card = state.cards.get(c);
    if (card.zone == kNoZone || card.host != kNoCard) continue;
    const uint32_t printed = data(card.cid).type;
    const ZoneKind k = state.zones.get(card.zone).kind;
    const bool deck_side = k == ZoneKind::LrigDeck || k == ZoneKind::LrigTrash || k == ZoneKind::Signi ||
                           k == ZoneKind::Cheer;
    if (printed & TYPE_RESONA) {
      if (!deck_side) {
        move_card(c, zone_of(c, ZoneKind::LrigDeck), REASON_RULE, kNoPlayer);
        any = true;
      }
    } else if (printed & (TYPE_LRIG | TYPE_ASSIST_LRIG | TYPE_KEY)) {
      const bool ok = deck_side || k == ZoneKind::LrigCenter || k == ZoneKind::LrigAssist || k == ZoneKind::Key;
      if (!ok) {
        move_card(c, zone_of(c, ZoneKind::LrigTrash), REASON_RULE, kNoPlayer);
        any = true;
      }
    }
  }

  // 8. 놓인·붙은 카드 상한 초과: 상한이 있는 붙는 카드 종류를 넣을 때 구현한다

  // 9. 시그니·키의 한정 조건이 센터 루리그 타입과 다르면 트래시
  for (PlayerId p : order) {
    if (center_lrig(p) == kNoCard) continue;
    std::vector<CardIdx> bad;
    for (CardIdx s : field_signi(p, true))
      if (!limit_cond_ok(s, p)) bad.push_back(s);
    if (CardIdx key = occupant(state.zones.find(p, ZoneKind::Key)); key != kNoCard && !limit_cond_ok(key, p))
      bad.push_back(key);
    for (CardIdx s : bad) move_card(s, zone_of(s, ZoneKind::Trash), REASON_RULE, kNoPlayer);
    any |= !bad.empty();
  }

  // 10. 루리그 타입이 완전히 같은 루리그가 여럿이면 센터가 아닌 쪽 묶음을 루리그 트래시로
  for (PlayerId p : order) {
    std::vector<CardIdx> lrigs;
    for (ZoneId z : state.zones.in_group(p, ZG_LRIG)) {
      const ZoneKind k = state.zones.get(z).kind;
      if (k != ZoneKind::LrigCenter && k != ZoneKind::LrigAssist) continue;
      if (CardIdx c = occupant(z); c != kNoCard) lrigs.push_back(c);
    }
    auto types = [&](CardIdx c) {
      auto t = lrig_types_of(c);
      std::sort(t.begin(), t.end());
      return t;
    };
    const CardIdx center = center_lrig(p);
    for (size_t i = 0; i < lrigs.size(); ++i)
      for (size_t j = i + 1; j < lrigs.size(); ++j) {
        if (types(lrigs[i]) != types(lrigs[j])) continue;
        CardIdx out = lrigs[i] == center ? lrigs[j] : lrigs[j] == center ? lrigs[i] : kNoCard;
        if (out == kNoCard) {
          Response r = co_await ask(pick_one(p, HINT_RULE_TRASH, {lrigs[i], lrigs[j]}));
          out = r.picks[0];
        }
        move_card(out, zone_of(out, ZoneKind::LrigTrash), REASON_RULE, kNoPlayer);
        any = true;
        co_return any;  // 장이 바뀌었으니 다시 훑는다
      }
  }

  // 다음 점검에서 「레벨이 바뀐 시그니」를 가리기 위해 지금 레벨을 적어 둔다
  last_levels_.clear();
  for (PlayerId p : order)
    for (CardIdx s : field_signi(p, true)) last_levels_[state.cards.get(s).oid] = level_of(s);
  co_return any;
}

}  // namespace wx
