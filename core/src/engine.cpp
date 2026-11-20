// 진행 엔진. 게임 흐름을 룰 문서 순서대로 쓴다.
// 근거: 용어집(ターン, 各フェイズ, アタックフェイズ, バトル, ダメージ, リフレッシュ, ターンを終了する),
//       faq.txt 「ゲーム開始時」
#include <algorithm>

#include "cost.h"
#include "duel.h"
#include "wx_api.h"

namespace wx {

namespace {
std::vector<uint32_t> as_options(const std::vector<CardIdx>& v) { return {v.begin(), v.end()}; }

Request cards_req(PlayerId p, uint32_t hint, const std::vector<CardIdx>& cands, uint32_t min, uint32_t max) {
  Request r;
  r.type = ReqType::SelectCards;
  r.player = p;
  r.hint = hint;
  r.options = as_options(cands);
  r.min = min;
  r.max = max;
  return r;
}

Request yesno_req(PlayerId p, uint32_t hint) {
  Request r;
  r.type = ReqType::YesNo;
  r.player = p;
  r.hint = hint;
  r.options = {0, 1};
  return r;
}
}  // namespace

// ── 바깥 인터페이스 ──

void Duel::start() {
  if (started_) return;
  started_ = true;
  root_ = game(true, PHASE_UP);
}

bool Duel::test_begin(PlayerId tp, uint32_t from_phase, bool first_turn) {
  if (!cfg_.test_mode) {
    log("테스트 모드가 꺼져 있어 test_begin을 거부");
    return false;
  }
  if (started_) return false;
  started_ = true;
  turn_player = tp;
  first_player = first_turn ? tp : opponent(tp);
  turn_count = first_turn ? 0 : 1;
  root_ = game(false, from_phase);
  return true;
}

Duel::Result Duel::process() {
  if (ended_ || !started_) return Result::End;
  if (pending_req_) return Result::NeedResponse;
  std::coroutine_handle<> h = resume_at_ ? std::exchange(resume_at_, {}) : root_.handle();
  if (!h || h.done()) {
    ended_ = true;
    return Result::End;
  }
  h.resume();
  if (root_.handle().done()) {
    ended_ = true;
    return Result::End;
  }
  return pending_req_ ? Result::NeedResponse : Result::Continue;
}

bool Duel::respond(Response r, std::string* why) {
  if (!pending_req_) return false;
  std::string reason;
  if (!validate(*pending_req_, r, reason)) {
    if (why) *why = reason;
    msg_retry(pending_req_->player, reason);
    return false;
  }
  response_ = std::move(r);
  pending_req_.reset();
  return true;
}

// ── 게임 ──

Task<> Duel::game(bool do_setup, uint32_t from_phase) {
  try {
    if (do_setup) co_await setup();
    msg_start();
    co_await turn(from_phase);
    for (;;) co_await turn(PHASE_UP);
  } catch (const GameEnd& g) {
    winner_ = g.winner;
  }
  msg_player(WX_MSG_WIN, winner_);
}

// faq.txt 「ゲーム開始時」 1~5
Task<> Duel::setup() {
  CardIdx start_center[2] = {kNoCard, kNoCard};
  std::vector<CardIdx> start_assists[2];
  for (PlayerId p = 0; p < 2; ++p) {
    // 1. 레벨 0 루리그 1장 또는 3장(용어집: ルリグゾーン). 덱에는 3장 넘게 들어갈 수 있으므로 고른다
    const ZoneId ldeck = state.zones.find(p, ZoneKind::LrigDeck);
    std::vector<CardIdx> zero;
    for (CardIdx c : state.zones.get(ldeck).cards) {
      const CardData& d = data(state.cards.get(c).cid);
      if ((d.type & (TYPE_LRIG | TYPE_ASSIST_LRIG)) && d.level == 0) zero.push_back(c);
    }
    if (zero.empty()) continue;
    auto is_lrig = [this](CardIdx c) { return (data(state.cards.get(c).cid).type & TYPE_LRIG) != 0; };
    std::vector<CardIdx> chosen = zero;
    if (zero.size() > 1) {
      Request r = cards_req(p, HINT_START_LRIG, zero, 1, zero.size() >= 3 ? 3 : 1);
      r.check = [is_lrig](const std::vector<uint32_t>& picks, std::string& why) {
        if (picks.size() == 2) {
          why = "시작 루리그는 1장 또는 3장";
          return false;
        }
        if (std::none_of(picks.begin(), picks.end(), is_lrig)) {
          why = "센터가 될 루리그가 없음";
          return false;
        }
        return true;
      };
      Response res = co_await ask(std::move(r));
      chosen.assign(res.picks.begin(), res.picks.end());
    }
    // 장에는 5(오픈)에서 놓는다. 그 전에는 뒷면이라 상대에게 보이지 않는다
    std::vector<CardIdx> centers;
    for (CardIdx c : chosen)
      if (is_lrig(c)) centers.push_back(c);
    if (centers.empty()) continue;
    start_center[p] = centers.front();
    if (chosen.size() == 3 && centers.size() > 1) {
      Response r = co_await ask(cards_req(p, HINT_CENTER_LRIG, centers, 1, 1));
      start_center[p] = r.picks[0];
    }
    if (chosen.size() == 3)
      for (CardIdx c : chosen)
        if (c != start_center[p]) start_assists[p].push_back(c);
  }

  // 2. 선공
  first_player = cfg_.first_player != kNoPlayer ? cfg_.first_player : static_cast<PlayerId>(state.rng.below(2));
  turn_player = first_player;

  // 3. 셔플, 5장, 引き直し(선공부터 선언, 동시에 처리. 용어집: 引き直し)
  for (PlayerId p = 0; p < 2; ++p) {
    state.shuffle(state.zones.find(p, ZoneKind::MainDeck));
    draw(p, 5, REASON_RULE);
  }
  std::vector<CardIdx> back[2];
  for (PlayerId p : {first_player, opponent(first_player)}) {
    const auto hand = state.zones.get(state.zones.find(p, ZoneKind::Hand)).cards;
    Response r = co_await ask(cards_req(p, HINT_MULLIGAN, hand, 0, static_cast<uint32_t>(hand.size())));
    back[p].assign(r.picks.begin(), r.picks.end());
  }
  for (PlayerId p = 0; p < 2; ++p) {
    const ZoneId deck = state.zones.find(p, ZoneKind::MainDeck);
    for (CardIdx c : back[p]) state.move(c, deck);
    if (!back[p].empty()) {
      state.shuffle(deck);
      draw(p, static_cast<uint32_t>(back[p].size()), REASON_RULE);
    }
  }

  // 4. 라이프 클로스 7장
  for (PlayerId p = 0; p < 2; ++p) {
    const ZoneId deck = state.zones.find(p, ZoneKind::MainDeck);
    const ZoneId life = state.zones.find(p, ZoneKind::LifeCloth);
    for (int i = 0; i < 7; ++i)
      if (CardIdx c = top_of(deck); c != kNoCard) state.move(c, life);
  }

  // 5. 오픈
  for (PlayerId p = 0; p < 2; ++p) {
    if (start_center[p] == kNoCard) continue;
    state.move(start_center[p], state.zones.find(p, "lrig_center"));
    const char* assists[] = {"lrig_assist_left", "lrig_assist_right"};
    for (size_t i = 0; i < start_assists[p].size() && i < 2; ++i)
      state.move(start_assists[p][i], state.zones.find(p, assists[i]));
  }
  pending_[0].clear();
  pending_[1].clear();
  turn_count = 0;
}

Task<> Duel::turn(uint32_t from) {
  ++turn_count;
  msg_turn();
  players[0].refreshes_this_turn = players[1].refreshes_this_turn = 0;
  grew_this_turn_ = removed_this_turn_ = false;
  bool forced = false;
  try {
    if (from <= PHASE_UP) co_await up_phase();
    if (from <= PHASE_DRAW) co_await draw_phase();
    if (from <= PHASE_ENA) co_await ena_phase();
    if (from <= PHASE_GROW) co_await grow_phase();
    if (from <= PHASE_MAIN) co_await main_phase();
    if (from <= PHASE_ATTACK) co_await attack_phase();
    co_await end_phase();
  } catch (const TurnEnd&) {
    forced = true;
  }
  if (forced) co_await forced_turn_end();
  turn_player = opponent(turn_player);
}

// 용어집: アップフェイズ, 凍結
Task<> Duel::up_phase() {
  enter_phase(PHASE_UP);
  std::vector<CardIdx> mine;
  for (ZoneId z : state.zones.in_group(turn_player, ZG_FIELD))
    if (CardIdx c = occupant(z); c != kNoCard) mine.push_back(c);
  for (CardIdx c : mine)
    if (!(state.cards.get(c).flags & CF_FROZEN)) set_flags(c, state.cards.get(c).flags & ~CF_DOWN);
  for (CardIdx c : mine) set_flags(c, state.cards.get(c).flags & ~CF_FROZEN);
  co_await resolve();
}

// 용어집: ドローフェイズ, 先攻
Task<> Duel::draw_phase() {
  enter_phase(PHASE_DRAW);
  const bool first_turn = turn_player == first_player && turn_count == 1;
  const ZoneId deck = state.zones.find(turn_player, ZoneKind::MainDeck);
  for (int i = 0; i < (first_turn ? 1 : 2); ++i) {
    if (draw(turn_player, 1, REASON_RULE) == 0) break;
    if (state.zones.get(deck).cards.empty()) break;  // 리프레시하고 그대로 엔나 페이즈로
  }
  co_await resolve();
}

// 용어집: エナフェイズ. 패 1장 또는 장의 시그니 1체, 하지 않아도 된다
Task<> Duel::ena_phase() {
  enter_phase(PHASE_ENA);
  std::vector<CardIdx> cands = state.zones.get(state.zones.find(turn_player, ZoneKind::Hand)).cards;
  for (ZoneId z : state.zones.in_group(turn_player, ZG_FIELD)) {
    const ZoneKind k = state.zones.get(z).kind;
    if (k != ZoneKind::Signi && k != ZoneKind::Cheer) continue;
    if (CardIdx c = occupant(z); c != kNoCard) cands.push_back(c);
  }
  if (!cands.empty()) {
    Response r = co_await ask(cards_req(turn_player, HINT_ENA_CHARGE, cands, 0, 1));
    if (!r.picks.empty())
      move_card(r.picks[0], state.zones.find(turn_player, ZoneKind::Ena), REASON_RULE, turn_player);
  }
  co_await resolve();
}

// 용어집: グロウ, faq.txt 「グロウの手順」
Task<> Duel::grow_phase() {
  enter_phase(PHASE_GROW);
  const CardIdx center = center_lrig(turn_player);
  if (center != kNoCard && !grew_this_turn_) {
    std::vector<uint8_t> ena_colors;
    for (CardIdx e : state.zones.get(state.zones.find(turn_player, ZoneKind::Ena)).cards)
      ena_colors.push_back(color_of(e));
    const auto center_types = classes_of(center);
    std::vector<CardIdx> cands;
    for (CardIdx c : state.zones.get(state.zones.find(turn_player, ZoneKind::LrigDeck)).cards) {
      if (!(type_of(c) & TYPE_LRIG) || level_of(c) != level_of(center) + 1) continue;
      const auto types = classes_of(c);
      if (std::none_of(types.begin(), types.end(), [&](uint32_t t) {
            return std::find(center_types.begin(), center_types.end(), t) != center_types.end();
          }))
        continue;
      if (!ena_can_pay(parse_ena_cost(data(text_of(c)).grow_ena), ena_colors)) continue;
      cands.push_back(c);
    }
    if (!cands.empty()) {
      Response r = co_await ask(cards_req(turn_player, HINT_GROW, cands, 0, 1));
      if (!r.picks.empty()) {
        const CardIdx next = r.picks[0];
        auto paid = co_await pay_ena(turn_player, data(text_of(next)).grow_ena);
        const ZoneId trash = state.zones.find(turn_player, ZoneKind::Trash);
        for (CardIdx e : paid) move_card(e, trash, REASON_COST, turn_player);
        // 겹친다: 이전 루리그와 그 아래 카드가 새 루리그 아래로
        const ZoneId cz = state.cards.get(center).zone;
        move_card(next, cz, REASON_RULE, turn_player);
        Card& old = state.cards.get(center);
        Card& nw = state.cards.get(next);
        for (CardIdx u : old.under) {
          nw.under.push_back(u);
          state.cards.get(u).host = next;
        }
        old.under.clear();
        state.put_under(center, next);
        Event ev;
        ev.code = EVENT_GROW;
        ev.cards = {next};
        ev.player = turn_player;
        ev.reason_player = turn_player;
        raise(ev);
        grew_this_turn_ = true;
      }
    }
  }
  co_await resolve();
}

Task<std::vector<CardIdx>> Duel::pay_ena(PlayerId p, const std::string& cost, bool cancelable) {
  const auto sym = parse_ena_cost(cost);
  if (sym.empty()) co_return std::vector<CardIdx>{};
  const auto& ena = state.zones.get(state.zones.find(p, ZoneKind::Ena)).cards;
  Request r = cards_req(p, HINT_PAY_ENA, ena, static_cast<uint32_t>(sym.size()), static_cast<uint32_t>(sym.size()));
  r.cancelable = cancelable;
  r.check = [this, sym](const std::vector<uint32_t>& picks, std::string& why) {
    std::vector<uint8_t> colors;
    for (uint32_t c : picks) colors.push_back(color_of(c));
    if (ena_pays(sym, colors)) return true;
    why = "고른 에나가 비용 색과 맞지 않음";
    return false;
  };
  Response res = co_await ask(std::move(r));
  co_return std::vector<CardIdx>(res.picks.begin(), res.picks.end());
}

// 용어집: メインフェイズ, リムーブする
Task<> Duel::main_phase() {
  enter_phase(PHASE_MAIN);
  for (;;) {
    actions_.clear();
    std::vector<CardIdx> removable;
    for (ZoneId z : state.zones.in_group(turn_player, ZG_FIELD)) {
      const ZoneKind k = state.zones.get(z).kind;
      if (k != ZoneKind::Signi && k != ZoneKind::Cheer) continue;
      if (CardIdx c = occupant(z); c != kNoCard && !(type_of(c) & TYPE_RESONA)) removable.push_back(c);
    }
    const auto hand = state.zones.get(state.zones.find(turn_player, ZoneKind::Hand)).cards;
    for (CardIdx c : hand)
      for (ZoneId z : state.zones.zones_of(turn_player, ZoneKind::Signi))
        if (can_play_signi(c, z)) actions_.push_back({ActionKind::PlaySigni, c, z});
    if (!removed_this_turn_ && !removable.empty()) actions_.push_back({ActionKind::Remove});
    for (const Action& a : usable_actions(turn_player, TIMING_MAIN)) actions_.push_back(a);
    actions_.push_back({ActionKind::EndPhase});
    if (actions_.size() == 1 && !cfg_.always_ask) break;

    Request r;
    r.type = ReqType::SelectAction;
    r.player = turn_player;
    r.hint = HINT_MAIN;
    for (uint32_t i = 0; i < actions_.size(); ++i) r.options.push_back(i);
    Response res = co_await ask(std::move(r));
    const Action a = actions_[res.picks[0]];
    actions_.clear();
    if (a.kind == ActionKind::EndPhase) break;
    if (a.kind == ActionKind::PlaySigni) {
      move_card(a.card, a.zone, REASON_RULE, turn_player);
    } else if (a.kind == ActionKind::Remove) {
      Response pick = co_await ask(
          cards_req(turn_player, HINT_REMOVE, removable, 1, static_cast<uint32_t>(removable.size())));
      for (uint32_t c : pick.picks)
        move_card(c, state.zones.find(state.cards.get(c).owner, ZoneKind::Trash), REASON_RULE, turn_player);
      removed_this_turn_ = true;
    } else if (a.kind == ActionKind::UseCard || a.kind == ActionKind::UseAbility) {
      co_await use(a);
    }
    co_await resolve();
  }
  actions_.clear();
}

// 용어집: アタックフェイズ, シグニアタックステップ, バトル, ルリグアタックステップ, ガード
Task<> Duel::attack_phase() {
  if (turn_player == first_player && turn_count == 1) co_return;  // 선공 1턴째는 건너뛴다
  enter_phase(PHASE_ATTACK);
  const PlayerId tp = turn_player, opp = opponent(tp);

  // 프리어택 스텝: 「アタックフェイズ開始時」
  Event start;
  start.code = EVENT_PHASE_START + PHASE_ATTACK;
  start.player = tp;
  raise(start);
  co_await resolve();
  // 프리어택 스텝 → 디펜스 스텝: 【アタックフェイズ】 아츠·능력(faq.txt 「アタックフェイズ」)
  co_await use_window(tp, TIMING_ATTACK, HINT_PRE_ATTACK);
  co_await use_window(opp, TIMING_ATTACK, HINT_DEFENSE);

  // 시그니 어택 스텝
  for (;;) {
    std::vector<CardIdx> attackers;
    for (ZoneId z : state.zones.zones_of(tp, ZoneKind::Signi))
      if (CardIdx c = occupant(z); c != kNoCard && !(state.cards.get(c).flags & CF_DOWN)) attackers.push_back(c);
    if (attackers.empty()) break;
    Response r = co_await ask(cards_req(tp, HINT_ATTACK_SIGNI, attackers, 0, 1));
    if (r.picks.empty()) break;
    const CardIdx a = r.picks[0];
    const ObjId oid = state.cards.get(a).oid;
    set_flags(a, state.cards.get(a).flags | CF_DOWN);
    msg_attack(a);
    Event ev;
    ev.code = EVENT_ATTACK;
    ev.cards = {a};
    ev.player = tp;
    ev.reason_player = tp;
    raise(ev);
    co_await resolve();
    // 「アタックしたとき」 처리 중 어택한 시그니가 장을 떠나면 배틀·데미지 없음(WXDi-P08-080 FAQ 1)
    if (state.cards.get(a).oid != oid) continue;

    const ZoneId front = state.zones.front(state.cards.get(a).zone);
    const CardIdx def = front != kNoZone ? occupant(front) : kNoCard;
    if (def != kNoCard) {
      const int32_t ap = power_of(a), dp = power_of(def);
      msg_battle(a, def, ap, dp);
      if (ap >= dp) banish(def, REASON_BATTLE, tp);
    } else {
      co_await damage(opp, 1, tp);  // 정면 존이 지워졌어도 데미지(WXK03-005 FAQ 4)
    }
    co_await resolve();
  }

  // 루리그 어택 스텝 → 가드 스텝
  const CardIdx center = center_lrig(tp);
  if (center != kNoCard && !(state.cards.get(center).flags & CF_DOWN)) {
    Response r = co_await ask(cards_req(tp, HINT_ATTACK_LRIG, {center}, 0, 1));
    if (!r.picks.empty()) {
      const ObjId oid = state.cards.get(center).oid;
      set_flags(center, state.cards.get(center).flags | CF_DOWN);
      msg_attack(center);
      Event ev;
      ev.code = EVENT_ATTACK;
      ev.cards = {center};
      ev.player = tp;
      ev.reason_player = tp;
      raise(ev);
      co_await resolve();
      if (state.cards.get(center).oid == oid) {
        std::vector<CardIdx> guards;
        for (CardIdx c : state.zones.get(state.zones.find(opp, ZoneKind::Hand)).cards)
          if (data(text_of(c)).guard) guards.push_back(c);
        bool guarded = false;
        if (!guards.empty()) {
          Response g = co_await ask(cards_req(opp, HINT_GUARD, guards, 0, 1));
          if (!g.picks.empty()) {
            move_card(g.picks[0], state.zones.find(opp, ZoneKind::Trash), REASON_DISCARD, opp);
            guarded = true;
          }
        }
        if (!guarded) co_await damage(opp, 1, tp);
        co_await resolve();
      }
    }
  }
}

// ── 사용(使用する) ──

std::vector<CardIdx> Duel::cards_in(PlayerId p, uint32_t self_loc, uint32_t opp_loc) {
  std::vector<CardIdx> out;
  for (ZoneId z = 0; z < state.zones.size(); ++z) {
    const Zone& zone = state.zones.get(z);
    const uint32_t mask = zone.owner == p ? self_loc : opp_loc;
    if (zone.absent || !(loc_bit(zone.kind) & mask)) continue;
    out.insert(out.end(), zone.cards.begin(), zone.cards.end());
  }
  return out;
}

std::vector<Action> Duel::usable_actions(PlayerId p, uint32_t timing) {
  std::vector<Action> out;
  auto activate_of = [&](CardIdx c) {
    EffectId id = kNoEffect;
    const Cid text = text_of(c);
    effects.for_each([&](Effect& e) {
      if (!id && e.handler == c && (e.type & EFFECT_TYPE_ACTIVATE) && e.printed && e.text_cid == text) id = e.id;
    });
    return id;
  };
  // 스펠: 자기 턴 메인 페이즈(용어집: スペル)
  if ((timing & TIMING_MAIN) && p == turn_player)
    for (CardIdx c : state.zones.get(state.zones.find(p, ZoneKind::Hand)).cards)
      if ((type_of(c) & TYPE_SPELL) && limit_cond_ok(c, p))
        if (EffectId e = activate_of(c)) out.push_back({ActionKind::UseCard, c, kNoZone, e, p});
  // 아츠: 사용 타이밍이 맞는 것(용어집: アーツ, 使用タイミング)
  for (CardIdx c : state.zones.get(state.zones.find(p, ZoneKind::LrigDeck)).cards)
    if ((type_of(c) & TYPE_ARTS) && (data(text_of(c)).timing & timing) && limit_cond_ok(c, p))
      if (EffectId e = activate_of(c)) out.push_back({ActionKind::UseCard, c, kNoZone, e, p});
  // 【起】
  std::vector<Effect*> ign;
  effects.for_each([&](Effect& e) {
    if ((e.type & EFFECT_TYPE_IGNITION) && e.handler != kNoCard) ign.push_back(&e);
  });
  for (Effect* e : ign) {
    if (state.cards.get(e->handler).controller != p || !effect_live(*e)) continue;
    if (!((e->timing ? e->timing : TIMING_MAIN) & timing)) continue;
    if (!ability_active(*e) || effect_suppressed(*e)) continue;
    out.push_back({ActionKind::UseAbility, e->handler, kNoZone, e->id, p});
  }
  std::erase_if(out, [&](const Action& a) { return !can_use(a); });
  return out;
}

bool Duel::can_use(const Action& a) {
  Effect* e = effects.get(a.effect);
  if (!e) return false;
  Pending t;
  t.effect = e->id;
  t.handler = a.card;
  t.player = a.player;
  if (e->condition_ref && !call_trigger_check(e->condition_ref, t, false)) return false;
  if (e->target_ref && !call_trigger_check(e->target_ref, t, true)) return false;
  const std::string& cost = a.kind == ActionKind::UseCard ? data(text_of(a.card)).cost_ena : e->ena_cost;
  std::vector<uint8_t> colors;
  for (CardIdx c : state.zones.get(state.zones.find(a.player, ZoneKind::Ena)).cards) colors.push_back(color_of(c));
  return ena_can_pay(parse_ena_cost(cost), colors);
}

// 1 선언 → 2 코스트 → 3 대상 → 4 컷인(스펠) → 5 효과 → 6 트래시(faq.txt 「スペルの使用手順」).
// 확정 전(2의 에나 선택, 3의 대상 선택)에는 상태를 바꾸지 않고, 취소하면 처음으로 돌아간다(설계: 확정 전 취소).
Task<bool> Duel::use(Action a) {
  const PlayerId p = a.player;
  const bool is_card = a.kind == ActionKind::UseCard;
  const EffectId eid = a.effect;
  Pending t;
  t.effect = eid;
  t.handler = a.card;
  t.player = p;

  chain.push_back(ActCtx{eid, p, a.card, {}, true});
  std::vector<CardIdx> paid;
  bool canceled = false;
  try {
    const std::string cost = is_card ? data(text_of(a.card)).cost_ena : effects.get(eid)->ena_cost;
    paid = co_await pay_ena(p, cost, true);
    if (effects.get(eid)->target_ref) co_await run_lua(effects.get(eid)->target_ref, t, true);
  } catch (const Canceled&) {
    canceled = true;
  }
  if (canceled) {
    chain.pop_back();
    co_return false;
  }
  // ── 확정 ──
  chain.back().cancelable = false;
  if (is_card) move_card(a.card, state.zones.find(p, ZoneKind::Check), REASON_RULE, p);
  for (CardIdx c : paid) move_card(c, state.zones.find(state.cards.get(c).owner, ZoneKind::Trash), REASON_COST, p);
  if (effects.get(eid)->cost_ref) co_await run_lua(effects.get(eid)->cost_ref, t, false);
  // 컷인 효과까지 처리한 뒤 스펠 효과를 처리한다. 그 사이 룰 처리·트리거는 미룬다(용어집: トリガー能力 2)
  if (is_card && (type_of(a.card) & TYPE_SPELL)) co_await use_window(opponent(p), TIMING_CUTIN, HINT_CUTIN);
  msg_trigger(t);
  if (effects.get(eid)->operation_ref) co_await run_lua(effects.get(eid)->operation_ref, t, false);
  if (is_card) {
    const Card& c = state.cards.get(a.card);
    if (c.zone != kNoZone && state.zones.get(c.zone).kind == ZoneKind::Check) {
      const bool arts = data(c.cid).type & TYPE_ARTS;
      move_card(a.card, state.zones.find(c.owner, arts ? ZoneKind::LrigTrash : ZoneKind::Trash), REASON_RULE, p);
    }
  }
  chain.pop_back();
  co_return true;
}

Task<> Duel::use_window(PlayerId p, uint32_t timing, uint32_t hint) {
  for (;;) {
    actions_ = usable_actions(p, timing);
    if (actions_.empty() && !cfg_.always_ask) break;
    actions_.push_back({ActionKind::EndPhase, kNoCard, kNoZone, kNoEffect, p});
    Request r;
    r.type = ReqType::SelectAction;
    r.player = p;
    r.hint = hint;
    for (uint32_t i = 0; i < actions_.size(); ++i) r.options.push_back(i);
    Response res = co_await ask(std::move(r));
    const Action a = actions_[res.picks[0]];
    actions_.clear();
    if (a.kind == ActionKind::EndPhase) break;
    const bool done = co_await use(a);
    if (done && timing != TIMING_CUTIN) co_await resolve();
  }
  actions_.clear();
}

// 용어집: ダメージ, ライフクロス, クラッシュ
Task<> Duel::damage(PlayerId p, uint32_t crush, PlayerId by) {
  const ZoneId life = state.zones.find(p, ZoneKind::LifeCloth);
  msg_player(WX_MSG_DAMAGE, p);
  if (state.zones.get(life).cards.empty()) throw GameEnd{opponent(p)};
  const ZoneId check = state.zones.find(p, ZoneKind::Check);
  for (uint32_t i = 0; i < crush; ++i) {
    const CardIdx c = top_of(life);
    if (c == kNoCard) break;
    move_card(c, check, REASON_DAMAGE, by);
    crushed_.push_back(c);
    Event ev;
    ev.code = EVENT_CRUSHED;
    ev.cards = {c};
    ev.player = p;
    ev.reason_player = by;
    raise(ev);
  }
  Event ev;
  ev.code = EVENT_DAMAGE;
  ev.player = p;
  ev.reason_player = by;
  raise(ev);
  co_return;
}

// 용어집: エンドフェイズ ①②③
Task<> Duel::end_phase() {
  enter_phase(PHASE_END);
  Event ev;
  ev.code = EVENT_TURN_END;
  ev.player = turn_player;
  raise(ev);
  co_await resolve();

  const ZoneId hand = state.zones.find(turn_player, ZoneKind::Hand);
  const auto cards = state.zones.get(hand).cards;
  if (cards.size() > 6) {
    const uint32_t n = static_cast<uint32_t>(cards.size() - 6);
    Response r = co_await ask(cards_req(turn_player, HINT_DISCARD, cards, n, n));
    for (uint32_t c : r.picks)
      move_card(c, state.zones.find(turn_player, ZoneKind::Trash), REASON_DISCARD | REASON_RULE, turn_player);
    co_await resolve();
  }
  reset_phase(PHASE_END);
  co_await resolve();
}

// 용어집: ターンを終了する 1~5
// 2에서 버리는 건 그때 이미 트리거해 있던 능력뿐이다. 3·5에서 새로 트리거한 능력은 처리한다(사용자 결정).
Task<> Duel::forced_turn_end() {
  enter_phase(PHASE_END);
  for (PlayerId p = 0; p < 2; ++p) {
    const ZoneId check = state.zones.find(p, ZoneKind::Check);
    for (CardIdx c : std::vector<CardIdx>(state.zones.get(check).cards))
      move_card(c, state.zones.find(state.cards.get(c).owner, ZoneKind::Trash), REASON_RULE, kNoPlayer);
  }
  crushed_.clear();
  pending_[0].clear();
  pending_[1].clear();
  end_turn_requested_ = false;
  try {
    co_await resolve();

    const ZoneId hand = state.zones.find(turn_player, ZoneKind::Hand);
    const auto cards = state.zones.get(hand).cards;
    if (cards.size() > 6) {
      const uint32_t n = static_cast<uint32_t>(cards.size() - 6);
      Response r = co_await ask(cards_req(turn_player, HINT_DISCARD, cards, n, n));
      for (uint32_t c : r.picks)
        move_card(c, state.zones.find(turn_player, ZoneKind::Trash), REASON_DISCARD | REASON_RULE, turn_player);
      co_await resolve();
    }
  } catch (const TurnEnd&) {
    // 이미 턴을 끝내는 중이다
  }
  reset_phase(PHASE_END);
  try {
    co_await resolve();
  } catch (const TurnEnd&) {
  }
  end_turn_requested_ = false;
}

// ── 룰 처리 → 트리거 ──
// 효과 하나를 처리할 때마다 룰 처리를 먼저 하고, 턴 플레이어 트리거부터 고른다.
// 새로 트리거한 것도 포함해 매번 턴 플레이어 쪽이 먼저다(faq.txt 「トリガー能力」).

Task<> Duel::resolve() {
  for (;;) {
    while (co_await rule_processing()) {
    }
    if (end_turn_requested_) {
      end_turn_requested_ = false;
      throw TurnEnd{};
    }
    PlayerId p = kNoPlayer;
    if (!pending_[turn_player].empty())
      p = turn_player;
    else if (!pending_[opponent(turn_player)].empty())
      p = opponent(turn_player);
    if (p == kNoPlayer) co_return;

    auto& q = pending_[p];
    size_t idx = 0;
    if (q.size() > 1) {  // 동시 트리거 순서는 매번 묻는다
      Request r;
      r.type = ReqType::SelectOption;
      r.player = p;
      r.hint = HINT_TRIGGER_ORDER;
      for (uint32_t i = 0; i < q.size(); ++i) r.options.push_back(i);
      Response res = co_await ask(std::move(r));
      idx = res.picks[0];
    }
    Pending t = std::move(q[idx]);
    q.erase(q.begin() + static_cast<std::ptrdiff_t>(idx));
    co_await resolve_trigger(std::move(t));
  }
}

Task<> Duel::resolve_trigger(Pending t) {
  msg_trigger(t);
  if (Effect* e = effects.get(t.effect)) {
    // 쓸 수 있는가(chk==0). 못 쓰면 묻지 않고 넘어간다
    bool use = !e->target_ref || call_trigger_check(e->target_ref, t, true);
    if (use && (e->type & EFFECT_TYPE_TRIGGER_O)) {
      Response r = co_await ask(yesno_req(t.player, HINT_USE_TRIGGER));
      use = r.picks[0] == 1;
    }
    if (use) {
      chain.push_back(ActCtx{t.effect, t.player, t.handler, {}, false});
      co_await run_lua(0, t, false);
      chain.pop_back();
    }
  }
  // 라이프 버스트가 끝난 카드는 에나 존으로(용어집: ライフバースト)
  if (t.burst_card != kNoCard) {
    const Card& c = state.cards.get(t.burst_card);
    if (c.zone != kNoZone && state.zones.get(c.zone).kind == ZoneKind::Check)
      move_card(t.burst_card, state.zones.find(c.owner, ZoneKind::Ena), REASON_RULE, kNoPlayer);
  }
}

}  // namespace wx
