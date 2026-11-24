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
    else msg_start();  // 준비 절차가 있으면 선공을 정한 그 자리에서 보낸다
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
  // じゃんけんに勝ったプレイヤーは先攻(용어집: ターン). 코어 PRNG로 정하고 바로 알린다(프레임은 코인토스로 보여 준다)
  first_player = cfg_.first_player != kNoPlayer ? cfg_.first_player : static_cast<PlayerId>(state.rng.below(2));
  turn_player = first_player;
  msg_start();

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
    // 센터 루리그 오픈 때만 코인을 얻는다. 어시스트는 얻지 않는다(용어집: コイン)
    gain_coin(p, data(state.cards.get(start_center[p]).cid).coin);
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
  players[0].opp_to_deck_this_turn = players[1].opp_to_deck_this_turn = 0;
  effects.for_each([](Effect& e) {
    if (!e.count_game) e.count_used = 0;
  });
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
// 센터 루리그만 그로우한다. 어시스트 루리그는 그 카드의 사용 타이밍에(faq.txt 「グロウフェイズ」)
Task<> Duel::grow_phase() {
  enter_phase(PHASE_GROW);
  const ZoneId cz = state.zones.find(turn_player, ZoneKind::LrigCenter);
  if (occupant(cz) != kNoCard && !grew_this_turn_) {
    std::vector<CardIdx> cands;
    for (CardIdx c : state.zones.get(state.zones.find(turn_player, ZoneKind::LrigDeck)).cards)
      if (can_grow(cz, c)) cands.push_back(c);
    if (!cands.empty()) {
      Response r = co_await ask(cards_req(turn_player, HINT_GROW, cands, 0, 1));
      if (!r.picks.empty()) {
        co_await grow(turn_player, cz, r.picks[0], false);
        grew_this_turn_ = true;
      }
    }
  }
  co_await resolve();
}

// 용어집: グロウ, アシストルリグ
bool Duel::can_grow(ZoneId z, CardIdx next) {
  const Zone& zone = state.zones.get(z);
  const CardIdx base = occupant(z);
  if (base == kNoCard || zone.absent) return false;
  const PlayerId p = zone.owner;
  if (state.cards.get(next).zone != state.zones.find(p, ZoneKind::LrigDeck)) return false;
  const uint32_t t = type_of(next);
  if (zone.kind == ZoneKind::LrigCenter) {
    // 센터 루리그 위에 어시스트 루리그를 겹칠 수 없다
    if (!(t & TYPE_LRIG) || (t & TYPE_ASSIST_LRIG)) return false;
  } else if (zone.kind == ZoneKind::LrigAssist) {
    // 어시스트 루리그로만, 센터 루리그보다 높은 레벨로는 그로우할 수 없다
    const CardIdx center = center_lrig(p);
    if (!(t & TYPE_ASSIST_LRIG) || center == kNoCard || level_of(next) > level_of(center)) return false;
  } else {
    return false;
  }
  if (level_of(next) != level_of(base) + 1) return false;
  const auto& base_types = lrig_types_of(base);
  const auto& types = lrig_types_of(next);
  if (std::none_of(types.begin(), types.end(), [&](uint32_t x) {
        return std::find(base_types.begin(), base_types.end(), x) != base_types.end();
      }))
    return false;
  return ena_can_pay(parse_ena_cost(data(text_of(next)).cost_ena), ena_colors(p));
}

// faq.txt 「グロウの手順」: 공개·선언 → 그로우 코스트 → 겹치기 → (룰 처리) → 【出】
Task<bool> Duel::grow(PlayerId p, ZoneId z, CardIdx next, bool cancelable) {
  std::vector<CardIdx> paid;
  bool canceled = false;
  try {
    paid = co_await pay_ena(p, data(text_of(next)).cost_ena, cancelable);
  } catch (const Canceled&) {
    canceled = true;
  }
  if (canceled) co_return false;
  const ZoneId trash = state.zones.find(p, ZoneKind::Trash);
  for (CardIdx e : paid) move_card(e, trash, REASON_COST, p);
  // 겹친다: 이전 루리그와 그 아래 카드가 새 루리그 아래로
  const CardIdx base = occupant(z);
  move_card(next, z, REASON_RULE, p);
  Card& old = state.cards.get(base);
  Card& nw = state.cards.get(next);
  for (CardIdx u : old.under) {
    nw.under.push_back(u);
    state.cards.get(u).host = next;
  }
  old.under.clear();
  state.put_under(base, next);
  // 센터로 장에 나오면 코인 아이콘만큼(PR-322 FAQ)
  if (state.zones.get(z).kind == ZoneKind::LrigCenter) gain_coin(p, data(text_of(next)).coin);
  Event ev;
  ev.code = EVENT_GROW;
  ev.cards = {next};
  ev.player = p;
  ev.reason_player = p;
  raise(ev);
  co_return true;
}

Task<std::vector<CardIdx>> Duel::pay_ena(PlayerId p, const std::string& cost, bool cancelable) {
  const auto sym = parse_ena_cost(cost);
  if (sym.empty()) co_return std::vector<CardIdx>{};
  const auto& ena = state.zones.get(state.zones.find(p, ZoneKind::Ena)).cards;
  Request r = cards_req(p, HINT_PAY_ENA, ena, static_cast<uint32_t>(sym.size()), static_cast<uint32_t>(sym.size()));
  r.cancelable = cancelable;
  r.check = [this, sym](const std::vector<uint32_t>& picks, std::string& why) {
    std::vector<uint8_t> colors;
    for (uint32_t c : picks) colors.push_back(pay_color(c));
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
        if (can_play_signi(c, z)) actions_.push_back({ActionKind::PlaySigni, c, z, kNoEffect, turn_player});
    if (!removed_this_turn_ && !removable.empty())
      actions_.push_back({ActionKind::Remove, kNoCard, kNoZone, kNoEffect, turn_player});
    // 키: 루리그 덱에서 코스트를 내고 키 존에(용어집: キー, faq.txt 「メインフェイズ」 3)
    for (CardIdx c : state.zones.get(state.zones.find(turn_player, ZoneKind::LrigDeck)).cards)
      if ((type_of(c) & TYPE_KEY) && can_play_key(turn_player, c))
        actions_.push_back({ActionKind::PlayKey, c, state.zones.find(turn_player, ZoneKind::Key), kNoEffect, turn_player});
    for (const Action& a : usable_actions(turn_player, TIMING_MAIN)) actions_.push_back(a);
    actions_.push_back({ActionKind::EndPhase, kNoCard, kNoZone, kNoEffect, turn_player});
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
    } else if (a.kind == ActionKind::UseCard || a.kind == ActionKind::UseAbility || a.kind == ActionKind::Grow ||
               a.kind == ActionKind::PlayKey || a.kind == ActionKind::PlayResona) {
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
      if (CardIdx c = occupant(z); c != kNoCard && !(state.cards.get(c).flags & CF_DOWN) && can_attack(c))
        attackers.push_back(c);
    if (attackers.empty()) break;
    // 「可能ならばアタックしなければならない」 시그니가 어택할 수 있으면 스텝을 끝낼 수 없다(WD07-004 FAQ 1)
    const bool must = std::any_of(attackers.begin(), attackers.end(), [&](CardIdx c) { return has_keyword(c, EFFECT_MUST_ATTACK); });
    Response r = co_await ask(cards_req(tp, HINT_ATTACK_SIGNI, attackers, must ? 1 : 0, 1));
    if (r.picks.empty()) break;
    const CardIdx a = r.picks[0];
    const ObjId oid = state.cards.get(a).oid;
    set_flags(a, state.cards.get(a).flags | CF_DOWN);
    msg_attack(a);
    extra_attackers_.clear();
    Event ev;
    ev.code = EVENT_ATTACK;
    ev.cards = {a};
    ev.player = tp;
    ev.reason_player = tp;
    raise(ev);
    // 어택으로 크로스한 시그니가 모두 다운이면 《ヘブン》. 「アタックしたとき」와 같은 때라 순서는 고른다(용어집: ヘブン 2)
    const std::vector<CardIdx> crossed = cross_group(a);
    if (!crossed.empty() &&
        std::all_of(crossed.begin(), crossed.end(), [&](CardIdx c) { return (state.cards.get(c).flags & CF_DOWN) != 0; })) {
      ev.code = EVENT_HEAVEN;
      ev.cards = crossed;
      raise(ev);
    }
    co_await resolve();
    // 「アタックしたとき」 처리 중 어택한 시그니가 장을 떠나면 배틀·데미지 없음(WXDi-P08-080 FAQ 1).
    // 「アタックしているシグニとして場に出す」로 나온 시그니는 【出】을 처리한 뒤 배틀·데미지(WDK-F03-15 FAQ 2)
    std::vector<CardIdx> battling;
    if (state.cards.get(a).oid == oid) battling.push_back(a);
    for (auto [c, o] : std::exchange(extra_attackers_, {}))
      if (state.cards.get(c).oid == o && (location_of(c) & LOCATION_SIGNI)) battling.push_back(c);
    for (CardIdx x : battling) {
      co_await signi_battle(x, tp);
      co_await resolve();
    }
  }
  co_await lrig_attack_step(tp, opp);
}

Task<> Duel::signi_battle(CardIdx a, PlayerId tp) {
  const PlayerId opp = opponent(tp);
  {
    // 【アサシン】: 정면에 시그니가 없는 것처럼(용어집: アサシン)
    const ZoneId front = state.zones.front(state.cards.get(a).zone);
    const CardIdx def = front != kNoZone && !has_keyword(a, EFFECT_ASSASSIN) ? occupant(front) : kNoCard;
    if (def != kNoCard) {
      const int32_t ap = power_of(a), dp = power_of(def);
      msg_battle(a, def, ap, dp);
      if (ap >= dp) {
        const bool s_lancer = has_keyword(a, EFFECT_S_LANCER);
        const bool lancer = s_lancer || has_keyword(a, EFFECT_LANCER);
        // 【ランサー】는 트리거 능력. 여러 개여도 1장(용어집: ランサー). 「バニッシュされない」로 바니시되지 않으면 트리거하지 않는다(룰 해설 171222)
        // 【Ｓランサー】와 같이 있으면 【Ｓランサー】 1번(용어집: Sランサー)
        if (banish(def, REASON_BATTLE, tp) && lancer) {
          Pending l;
          l.builtin = s_lancer ? Builtin::SLancer : Builtin::LancerCrush;
          l.handler = a;
          l.player = tp;
          pending_[tp].push_back(l);
        }
      }
    } else {
      // 정면 존이 지워졌어도 데미지(WXK03-005 FAQ 4). 【ダブルクラッシュ】는 몇 개여도 2장(용어집)
      co_await damage(opp, has_keyword(a, EFFECT_DOUBLE_CRUSH) ? 2 : 1, tp);
    }
  }
}

bool Duel::prevent_damage(PlayerId p) {
  EffectId used = kNoEffect;
  effects.for_each([&](Effect& e) {
    if (used != kNoEffect || e.code != EFFECT_PREVENT_DAMAGE || !(e.type & EFFECT_TYPE_FIELD) || !effect_live(e)) return;
    if (e.handler != kNoCard) return;  // 플레이어에 등록한 효과만(Duel.RegisterEffect)
    const PlayerId ctrl = e.owner_player;
    if ((p == ctrl && e.target_self) || (p != ctrl && e.target_opp)) used = e.id;
  });
  if (used == kNoEffect) return false;
  delete_effect(used);  // 「次に」: 한 번
  return true;
}

bool Duel::cannot_crush(PlayerId p) {
  bool no = false;
  effects.for_each([&](Effect& e) {
    if (no || e.code != EFFECT_CANNOT_CRUSH || !(e.type & EFFECT_TYPE_FIELD) || !effect_live(e)) return;
    if (e.handler != kNoCard) return;  // 플레이어에 등록한 효과만(Duel.RegisterEffect)
    const PlayerId ctrl = e.owner_player;
    no = (p == ctrl && e.target_self) || (p != ctrl && e.target_opp);
  });
  return no;
}

// 크러시되어 체크 존에 있던 카드를 에나로. CF_CRUSH_REFILL이면 대신 트래시 + 덱 위 1장을 라이프 클로스에(WD06-009, WD06-001 FAQ 1)
void Duel::crushed_to_ena(CardIdx c) {
  Card& card = state.cards.get(c);
  if (!(card.flags & CF_CRUSH_REFILL)) {
    move_card(c, state.zones.find(card.owner, ZoneKind::Ena), REASON_RULE, kNoPlayer);
    return;
  }
  card.flags &= ~CF_CRUSH_REFILL;
  const PlayerId p = card.owner;
  move_card(c, state.zones.find(p, ZoneKind::Trash), REASON_EFFECT, p);
  if (CardIdx top = top_of(state.zones.find(p, ZoneKind::MainDeck)); top != kNoCard)
    move_card(top, state.zones.find(p, ZoneKind::LifeCloth), REASON_EFFECT, p);
}

bool Duel::cannot_guard(PlayerId p, CardIdx c) {
  bool no = false;
  effects.for_each([&](Effect& e) {
    if (no || e.code != EFFECT_CANNOT_GUARD || !(e.type & EFFECT_TYPE_FIELD) || !effect_live(e)) return;
    if (e.handler != kNoCard) return;  // 플레이어에 등록한 효과만(Duel.RegisterEffect)
    const PlayerId ctrl = e.owner_player;
    if (!((p == ctrl && e.target_self) || (p != ctrl && e.target_opp))) return;
    if (type_of(c) & TYPE_SIGNI) no = level_of(c) == e.value;
  });
  return no;
}

Task<> Duel::lrig_attack_step(PlayerId tp, PlayerId opp) {
  // 루리그 어택 스텝 → 가드 스텝
  const CardIdx center = center_lrig(tp);
  if (center != kNoCard && !(state.cards.get(center).flags & CF_DOWN) && can_attack(center)) {
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
          if (data(text_of(c)).guard && !cannot_guard(opp, c)) guards.push_back(c);
        bool guarded = false;
        if (!guards.empty()) {
          Response g = co_await ask(cards_req(opp, HINT_GUARD, guards, 0, 1));
          if (!g.picks.empty()) {
            move_card(g.picks[0], state.zones.find(opp, ZoneKind::Trash), REASON_DISCARD, opp);
            guarded = true;
          }
        }
        if (!guarded) co_await damage(opp, has_keyword(center, EFFECT_DOUBLE_CRUSH) ? 2 : 1, tp);
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
  sync_grants();
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
  // 아츠: 사용 타이밍이 맞는 것(용어집: アーツ, 使用タイミング). 피스는 루리그가 3체일 때(용어집: ピース)
  const bool three = lrig_count(p) == 3;
  for (CardIdx c : state.zones.get(state.zones.find(p, ZoneKind::LrigDeck)).cards) {
    const uint32_t t = type_of(c);
    if (!(t & TYPE_ARTS) && !((t & TYPE_PIECE) && three)) continue;
    if ((data(text_of(c)).timing & timing) && limit_cond_ok(c, p))
      if (EffectId e = activate_of(c)) out.push_back({ActionKind::UseCard, c, kNoZone, e, p});
  }
  // 【起】
  std::vector<Effect*> ign;
  effects.for_each([&](Effect& e) {
    if ((e.type & EFFECT_TYPE_IGNITION) && e.handler != kNoCard) ign.push_back(&e);
  });
  for (Effect* e : ign) {
    if (state.cards.get(e->handler).controller != p || !effect_live(*e)) continue;
    if (!((e->timing ? e->timing : TIMING_MAIN) & timing)) continue;
    if (!ability_active(*e) || effect_suppressed(*e) || !count_ok(*e)) continue;
    out.push_back({ActionKind::UseAbility, e->handler, kNoZone, e->id, p});
  }
  std::erase_if(out, [&](const Action& a) { return !can_use(a); });
  // 레조나: 출현 조건의 타이밍이 맞고 조건을 채울 수 있는 것(faq.txt 「メインフェイズ」 2)
  for (CardIdx c : state.zones.get(state.zones.find(p, ZoneKind::LrigDeck)).cards) {
    if (!(type_of(c) & TYPE_RESONA)) continue;
    for (Effect* e : affecting(c, EFFECT_RESONA))
      if (((e->timing ? e->timing : TIMING_MAIN) & timing) && resona_feasible(c, *e)) {
        out.push_back({ActionKind::PlayResona, c, kNoZone, e->id, p});
        break;
      }
  }
  // 어시스트 루리그 그로우: 그 카드의 사용 타이밍에, 한 턴에 몇 번이든(용어집: アシストルリグ, faq.txt 「メインフェイズ」 5)
  const auto& ldeck = state.zones.get(state.zones.find(p, ZoneKind::LrigDeck)).cards;
  for (ZoneId z : state.zones.zones_of(p, ZoneKind::LrigAssist))
    for (CardIdx c : ldeck)
      if ((type_of(c) & TYPE_ASSIST_LRIG) && (data(text_of(c)).timing & timing) && can_grow(z, c))
        out.push_back({ActionKind::Grow, c, z, kNoEffect, p});
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
  if (a.kind == ActionKind::UseAbility && has_keyword(a.card, EFFECT_FREE_IGNITION)) return players[a.player].coins >= coin_cost(a);
  if (e->cost_ref && !call_trigger_check(e->cost_ref, t, true)) return false;
  if (players[a.player].coins < coin_cost(a)) return false;
  if (exceed_cards(a.player).size() < e->exceed) return false;
  std::string cost = a.kind == ActionKind::UseCard ? data(text_of(a.card)).cost_ena : e->ena_cost;
  if (a.kind == ActionKind::UseCard && e->min_cost_ref) cost = call_cost(e->min_cost_ref, e->id, a.player);
  if (ena_can_pay(parse_ena_cost(cost), ena_colors(a.player))) return true;
  return can_bet(a) && e->has_bet_cost && ena_can_pay(parse_ena_cost(e->bet_cost), ena_colors(a.player));
}

// ベット할 수 있는가: 아츠에 ベット가 있고 코스트 코인 + ベット 코인을 가졌다
bool Duel::can_bet(const Action& a) {
  const Effect* e = effects.get(a.effect);
  return a.kind == ActionKind::UseCard && e && e->bet && players[a.player].coins >= coin_cost(a) + e->bet;
}

std::vector<uint8_t> Duel::ena_colors(PlayerId p) {
  std::vector<uint8_t> colors;
  for (CardIdx c : state.zones.get(state.zones.find(p, ZoneKind::Ena)).cards) colors.push_back(pay_color(c));
  return colors;
}

// 1 선언 → 2 코스트 → 3 대상 → 4 컷인(스펠) → 5 효과 → 6 트래시(faq.txt 「スペルの使用手順」).
// 확정 전(2의 에나 선택, 3의 대상 선택)에는 상태를 바꾸지 않고, 취소하면 처음으로 돌아간다(설계: 확정 전 취소).
uint32_t Duel::coin_cost(const Action& a) {
  const Effect* e = effects.get(a.effect);
  uint32_t n = e ? e->coin_cost : 0;
  if (a.kind == ActionKind::UseCard) n += data(text_of(a.card)).cost_coin;
  return n;
}

Task<std::vector<CardIdx>> Duel::pick_exceed(PlayerId p, uint32_t n, bool cancelable) {
  if (n == 0) co_return std::vector<CardIdx>{};
  Request r = cards_req(p, HINT_EXCEED, exceed_cards(p), n, n);
  r.cancelable = cancelable;
  Response res = co_await ask(std::move(r));
  co_return std::vector<CardIdx>(res.picks.begin(), res.picks.end());
}

Task<bool> Duel::play_key(PlayerId p, CardIdx key) {
  std::vector<CardIdx> paid;
  bool canceled = false;
  try {
    paid = co_await pay_ena(p, data(text_of(key)).cost_ena, true);
  } catch (const Canceled&) {
    canceled = true;
  }
  if (canceled) co_return false;
  for (CardIdx c : paid) move_card(c, state.zones.find(state.cards.get(c).owner, ZoneKind::Trash), REASON_COST, p);
  pay_coin(p, data(text_of(key)).cost_coin);
  const ZoneId kz = state.zones.find(p, ZoneKind::Key);
  // 키는 1장까지. 2장째를 내면 먼저 것을 루리그 트래시에(용어집: キー)
  if (CardIdx old = occupant(kz); old != kNoCard)
    move_card(old, state.zones.find(state.cards.get(old).owner, ZoneKind::LrigTrash), REASON_RULE, p);
  move_card(key, kz, REASON_RULE, p);
  co_return true;
}

// ── 레조나(용어집: レゾナ, 出現条件) ──

std::vector<CardIdx> Duel::resona_candidates(CardIdx c, Effect& e) {
  const PlayerId p = state.cards.get(c).controller;
  std::vector<CardIdx> out;
  for (CardIdx x : cards_in(p, e.target_self ? e.target_self : LOCATION_SZONE, 0))
    if (x != c && (!e.target_ref || call_filter(e.target_ref, e.id, x))) out.push_back(x);
  return out;
}

// 출현 조건 카드가 떠난 뒤 레조나를 놓을 수 있는 시그니 존
std::vector<ZoneId> Duel::resona_zones(PlayerId p, const std::vector<CardIdx>& leaving) {
  std::vector<ZoneId> out;
  for (ZoneId z : state.zones.zones_of(p, ZoneKind::Signi)) {
    if (state.zones.get(z).absent || !front_ok(p, z)) continue;
    const CardIdx o = occupant(z);
    if (o == kNoCard || std::find(leaving.begin(), leaving.end(), o) != leaving.end()) out.push_back(z);
  }
  return out;
}

// 레벨은 루리그 레벨 이하, 낸 뒤 장의 레벨 합계가 리미트 이하(사용자 결정 2026-11-24. 출현 조건으로 떠나는 시그니는 빼고 센다)
bool Duel::resona_ok(CardIdx c, Effect& e, const std::vector<CardIdx>& mats, std::string* why,
                     const std::vector<CardIdx>* known) {
  auto fail = [&](const char* m) {
    if (why) *why = m;
    return false;
  };
  const PlayerId p = state.cards.get(c).controller;
  const size_t max = static_cast<size_t>(e.value);
  const size_t min = e.label > 0 ? static_cast<size_t>(e.label) : max;
  if (mats.size() < min || mats.size() > max) return fail("출현 조건 장수가 맞지 않음");
  const auto cand = known ? *known : resona_candidates(c, e);
  for (CardIdx m : mats)
    if (std::find(cand.begin(), cand.end(), m) == cand.end()) return fail("출현 조건에 맞지 않는 카드");
  if (e.check_ref && !call_group_check(e.check_ref, mats)) return fail("출현 조건에 맞지 않는 조합");
  const CardIdx center = center_lrig(p);
  if (center == kNoCard || level_of(c) > level_of(center)) return fail("루리그 레벨보다 높음");
  if (!limit_cond_ok(c, p)) return fail("한정 조건");
  int32_t sum = limit_cost_of(c);
  for (ZoneId s : state.zones.zones_of(p, ZoneKind::Signi))
    if (CardIdx o = occupant(s); o != kNoCard && std::find(mats.begin(), mats.end(), o) == mats.end())
      sum += limit_cost_of(o);
  if (sum > total_limit(p)) return fail("리미트를 넘음");
  if (resona_zones(p, mats).empty()) return fail("놓을 시그니 존이 없음");
  return true;
}

bool Duel::resona_feasible(CardIdx c, Effect& e) {
  const auto cand = resona_candidates(c, e);
  const size_t max = static_cast<size_t>(std::max(0, e.value));
  const size_t min = e.label > 0 ? static_cast<size_t>(e.label) : max;
  // 후보는 많지 않으므로 조합을 다 본다
  for (size_t k = min; k <= max && k <= cand.size(); ++k) {
    std::vector<size_t> idx(k);
    for (size_t i = 0; i < k; ++i) idx[i] = i;
    for (;;) {
      std::vector<CardIdx> mats;
      for (size_t i : idx) mats.push_back(cand[i]);
      if (resona_ok(c, e, mats, nullptr, &cand)) return true;
      size_t i = k;
      while (i > 0 && idx[i - 1] == cand.size() - k + i - 1) --i;
      if (i == 0) break;
      ++idx[i - 1];
      for (size_t j = i; j < k; ++j) idx[j] = idx[j - 1] + 1;
    }
  }
  return false;
}

// 조건만 채우고 내지 않을 수는 없다(WD09-007 FAQ 2). 출현 조건은 코스트·효과가 아니다(용어집: 出現条件)
Task<bool> Duel::play_resona(PlayerId p, CardIdx c, EffectId eid) {
  Effect& e = *effects.get(eid);
  const auto cand = resona_candidates(c, e);
  const uint32_t n = static_cast<uint32_t>(e.value);
  Request r = cards_req(p, HINT_RESONA, cand, e.label > 0 ? static_cast<uint32_t>(e.label) : n, n);
  r.source = c;
  r.cancelable = true;
  r.check = [this, c, eid](const std::vector<uint32_t>& picks, std::string& why) {
    return resona_ok(c, *effects.get(eid), std::vector<CardIdx>(picks.begin(), picks.end()), &why);
  };
  std::vector<CardIdx> mats;
  bool canceled = false;
  try {
    Response res = co_await ask(std::move(r));
    mats.assign(res.picks.begin(), res.picks.end());
  } catch (const Canceled&) {
    canceled = true;
  }
  if (canceled) co_return false;
  resona_raw_ = true;
  move_card(c, state.zones.find(p, ZoneKind::Check), REASON_RULE, p);
  resona_raw_ = false;
  int32_t levels = 0;
  for (CardIdx m : mats) levels += level_of(m);
  for (CardIdx m : mats)
    move_card(m, state.zones.find(state.cards.get(m).owner, ZoneKind::Trash),
              location_of(m) & LOCATION_HAND ? REASON_RULE | REASON_DISCARD : REASON_RULE, p);
  const auto zones = resona_zones(p, {});
  ZoneId z = zones.empty() ? kNoZone : zones.front();
  if (!zones.empty()) {
    Request zr;
    zr.type = ReqType::SelectOption;
    zr.player = p;
    zr.hint = HINT_ZONE;
    zr.source = c;
    zr.min = zr.max = 1;
    for (ZoneId x : zones) zr.options.push_back(x);
    z = static_cast<ZoneId>((co_await ask(std::move(zr))).picks[0]);
  }
  play_value_ = levels;
  if (z != kNoZone) move_card(c, z, REASON_RULE, p);
  play_value_ = 0;
  co_return true;
}

Task<bool> Duel::use(Action a) {
  if (a.kind == ActionKind::Grow) co_return co_await grow(a.player, a.zone, a.card, true);
  if (a.kind == ActionKind::PlayKey) co_return co_await play_key(a.player, a.card);
  if (a.kind == ActionKind::PlayResona) co_return co_await play_resona(a.player, a.card, a.effect);
  const PlayerId p = a.player;
  const bool is_card = a.kind == ActionKind::UseCard;
  const EffectId eid = a.effect;
  Pending t;
  t.effect = eid;
  t.handler = a.card;
  t.player = p;

  chain.push_back(ActCtx{eid, p, a.card, {}, true});
  std::vector<Effect*> frees = a.kind == ActionKind::UseAbility ? affecting(a.card, EFFECT_FREE_IGNITION) : std::vector<Effect*>{};
  const bool free = !frees.empty();
  const EffectId free_id = free ? frees.front()->id : kNoEffect;
  std::vector<CardIdx> paid, exceed;
  bool canceled = false, encore = false;
  const uint32_t coins = coin_cost(a);
  try {
    // ベット: 사용할 때 코인을 더 내도 된다. 코스트·모드·대상이 달라지므로 에나보다 먼저 묻는다(용어집: ベット, WDK-F03-10 FAQ 1, WDK08-Y06).
    // ベット 코스트로만 낼 수 있으면 묻지 않고 ベット한다
    const Effect& ue = *effects.get(eid);
    std::string cost = is_card ? data(text_of(a.card)).cost_ena : ue.ena_cost;
    // 「使用コストは《黒×0》になる」: 에나·그 밖의 코스트 모두 없다(WD08-001 FAQ 3)
    if (free) cost.clear();
    if (can_bet(a)) {
      const bool must = ue.has_bet_cost && !ena_can_pay(parse_ena_cost(cost), ena_colors(p));
      if (must) {
        chain.back().bet = true;
      } else {
        Request r = yesno_req(p, HINT_BET);
        r.cancelable = true;
        Response res = co_await ask(std::move(r));
        chain.back().bet = res.picks[0] == 1;
      }
      if (chain.back().bet && ue.has_bet_cost) cost = ue.bet_cost;
    }
    // 사용 선언 때 모드를 고른다. 코스트보다 먼저(faq 「スペルの使用手順」 1)
    if (ue.declare_ref) co_await run_lua(ue.declare_ref, t, false);
    if (chain.back().use_cost) cost = *chain.back().use_cost;
    paid = co_await pay_ena(p, cost, true);
    exceed = co_await pick_exceed(p, effects.get(eid)->exceed, true);
    // 앙코르 코스트는 카드 코스트와 같이 낸다(WDK09-006 FAQ 2, 용어집: アンコール)
    const uint32_t bet = chain.back().bet ? effects.get(eid)->bet : 0;
    if (is_card && effects.get(eid)->encore && players[p].coins >= coins + bet + effects.get(eid)->encore) {
      Request r = yesno_req(p, HINT_ENCORE);
      r.cancelable = true;
      Response res = co_await ask(std::move(r));
      encore = res.picks[0] == 1;
    }
  } catch (const Canceled&) {
    canceled = true;
  }
  if (canceled) {
    chain.pop_back();
    co_return false;
  }
  // ── 확정: 코스트를 실제로 낸다. 대상은 그 뒤에 고르고, 여기부터는 취소할 수 없다 ──
  // 코스트로 트래시에 간 카드도 대상이 될 수 있다(WD05-008 FAQ 2, WD05-018 FAQ 1). 에나를 떠났으니 에나 대상은 안 된다(WD04-007 FAQ 1)
  chain.back().cancelable = false;
  count_use(*effects.get(eid));
  if (is_card) move_card(a.card, state.zones.find(p, ZoneKind::Check), REASON_RULE, p);
  for (CardIdx c : paid) move_card(c, state.zones.find(state.cards.get(c).owner, ZoneKind::Trash), REASON_COST, p);
  for (CardIdx c : exceed)
    move_card(c, state.zones.find(state.cards.get(c).owner, ZoneKind::LrigTrash), REASON_COST, p);
  pay_coin(p, coins + (chain.back().bet ? effects.get(eid)->bet : 0) + (encore ? effects.get(eid)->encore : 0));
  if (free) delete_effect(free_id);  // 「次に」: 한 번
  if (!free && effects.get(eid)->cost_ref) co_await run_lua(effects.get(eid)->cost_ref, t, false);
  if (effects.get(eid)->target_ref) co_await run_lua(effects.get(eid)->target_ref, t, true);
  // 컷인 효과까지 처리한 뒤 스펠 효과를 처리한다. 그 사이 룰 처리·트리거는 미룬다(용어집: トリガー能力 2)
  if (is_card && (type_of(a.card) & TYPE_SPELL)) co_await use_window(opponent(p), TIMING_CUTIN, HINT_CUTIN);
  msg_trigger(t);
  if (effects.get(eid)->operation_ref) co_await run_lua(effects.get(eid)->operation_ref, t, false);
  flush_deck_moves();
  if (is_card) {
    const Card& c = state.cards.get(a.card);
    if (c.zone != kNoZone && state.zones.get(c.zone).kind == ZoneKind::Check) {
      // 아츠는 루리그 트래시, 피스는 게임에서 제외(용어집: ピース), 스펠은 트래시
      // 앙코르를 냈으면 루리그 덱으로 돌아간다
      const uint32_t type = data(c.cid).type;
      const ZoneKind to = encore                ? ZoneKind::LrigDeck
                          : (type & TYPE_PIECE) ? ZoneKind::Exclude
                          : (type & TYPE_ARTS)  ? ZoneKind::LrigTrash
                                                : ZoneKind::Trash;
      move_card(a.card, state.zones.find(c.owner, to), REASON_RULE, p);
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
Task<> Duel::damage(PlayerId p, uint32_t n, PlayerId by) {
  // 「代わりにダメージを受けない」: 대체는 강제이고, 라이프 클로스가 없을 때의 데미지(패배)도 대체한다(용어집: ダメージ)
  if (prevent_damage(p)) co_return;
  const ZoneId life = state.zones.find(p, ZoneKind::LifeCloth);
  msg_player(WX_MSG_DAMAGE, p);
  if (state.zones.get(life).cards.empty()) throw GameEnd{opponent(p)};
  crush(p, n, by);
  Event ev;
  ev.code = EVENT_DAMAGE;
  ev.player = p;
  ev.reason_player = by;
  raise(ev);
  co_return;
}

void Duel::crush(PlayerId p, uint32_t n, PlayerId by) {
  if (cannot_crush(p)) return;
  const ZoneId life = state.zones.find(p, ZoneKind::LifeCloth);
  const ZoneId check = state.zones.find(p, ZoneKind::Check);
  for (uint32_t i = 0; i < n; ++i) {
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
  // 손패 상한(기본 6, WDK09-009 FAQ 1)
  const size_t limit = static_cast<size_t>(std::max(0, hand_limit(turn_player)));
  if (cards.size() > limit) {
    const uint32_t n = static_cast<uint32_t>(cards.size() - limit);
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
    const size_t limit = static_cast<size_t>(std::max(0, hand_limit(turn_player)));
    if (cards.size() > limit) {
      const uint32_t n = static_cast<uint32_t>(cards.size() - limit);
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
      for (uint32_t i = 0; i < q.size(); ++i) {
        r.options.push_back(i);
        r.option_cards.push_back(q[i].handler);
        r.option_descs.push_back(desc_of(q[i].effect));
      }
      Response res = co_await ask(std::move(r));
      idx = res.picks[0];
    }
    Pending t = std::move(q[idx]);
    q.erase(q.begin() + static_cast<std::ptrdiff_t>(idx));
    co_await resolve_trigger(std::move(t));
  }
}

uint32_t Duel::desc_of(EffectId id) {
  Effect* e = effects.get(id);
  if (!e) return 0;
  if (e->desc) return e->desc;
  if ((e->type & EFFECT_TYPE_LIFEBURST) && e->handler != kNoCard) return lb_desc(e->handler);
  return 0;
}

Task<> Duel::resolve_trigger(Pending t) {
  msg_trigger(t);
  if (t.builtin == Builtin::LancerCrush) {
    crush(opponent(t.player), 1, t.player);
    co_return;
  }
  if (t.builtin == Builtin::SLancer) {
    // 라이프 클로스가 있으면 크러시(데미지가 아니다), 없으면 데미지(용어집: Sランサー)
    const PlayerId opp = opponent(t.player);
    if (state.zones.get(state.zones.find(opp, ZoneKind::LifeCloth)).cards.empty())
      co_await damage(opp, 1, t.player);
    else
      crush(opp, 1, t.player);
    co_return;
  }
  if (Effect* e = effects.get(t.effect)) {
    // 쓸 수 있는가(chk==0). 못 쓰면 묻지 않고 넘어간다
    bool use = count_ok(*e) && (!e->target_ref || call_trigger_check(e->target_ref, t, true));
    // 코스트가 있으면 낼 수 있을 때만, 내지 않고 발동하지 않을 수도 있다(WXDi-D01-010, WXDi-D01-015 FAQ 1)
    const bool has_cost = !e->ena_cost.empty() || e->cost_ref || e->coin_cost || e->exceed;
    if (use && has_cost)
      use = ena_can_pay(parse_ena_cost(e->ena_cost), ena_colors(t.player)) &&
            players[t.player].coins >= e->coin_cost && exceed_cards(t.player).size() >= e->exceed &&
            (!e->cost_ref || call_trigger_check(e->cost_ref, t, true));
    if (use && (has_cost || (e->type & EFFECT_TYPE_TRIGGER_O))) {
      Request yn = yesno_req(t.player, HINT_USE_TRIGGER);
      yn.source = t.handler;
      yn.source_desc = desc_of(t.effect);
      Response r = co_await ask(std::move(yn));
      use = r.picks[0] == 1;
    }
    if (use) {
      count_use(*e);
      chain.push_back(ActCtx{t.effect, t.player, t.handler, {}, false});
      if (has_cost) {
        const auto paid = co_await pay_ena(t.player, e->ena_cost);
        for (CardIdx c : paid)
          move_card(c, state.zones.find(state.cards.get(c).owner, ZoneKind::Trash), REASON_COST, t.player);
        for (CardIdx c : co_await pick_exceed(t.player, e->exceed, false))
          move_card(c, state.zones.find(state.cards.get(c).owner, ZoneKind::LrigTrash), REASON_COST, t.player);
        pay_coin(t.player, e->coin_cost);
        if (e->cost_ref) co_await run_lua(e->cost_ref, t, false);
      }
      co_await run_lua(0, t, false);
      flush_deck_moves();
      chain.pop_back();
    }
  }
  // 라이프 버스트가 끝난 카드는 에나 존으로(용어집: ライフバースト)
  if (t.burst_card != kNoCard) {
    const Card& c = state.cards.get(t.burst_card);
    if (c.zone != kNoZone && state.zones.get(c.zone).kind == ZoneKind::Check) crushed_to_ena(t.burst_card);
  }
}

}  // namespace wx
