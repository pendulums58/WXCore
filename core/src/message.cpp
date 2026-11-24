// 메시지 생성. 같은 사건도 뷰(P1/P2/관전/전부)마다 따로 만든다(설계: 정보 공개).
// 형식은 wx_api.h 머리말 참고.
#include "duel.h"
#include "wx_api.h"

namespace wx {

namespace {
struct Writer {
  std::vector<uint8_t>& b;
  void u8(uint8_t v) { b.push_back(v); }
  void u16(uint16_t v) {
    for (int i = 0; i < 2; ++i) b.push_back(static_cast<uint8_t>(v >> (8 * i)));
  }
  void u32(uint32_t v) {
    for (int i = 0; i < 4; ++i) b.push_back(static_cast<uint8_t>(v >> (8 * i)));
  }
  void i32(int32_t v) { u32(static_cast<uint32_t>(v)); }
  void str(const std::string& s, size_t max) {
    const size_t n = std::min(s.size(), max);
    b.insert(b.end(), s.begin(), s.begin() + static_cast<std::ptrdiff_t>(n));
  }
};

// 그 뷰가 이 카드를 아는가. 플레이어는 이동 전후 어느 쪽에서든 보면 안다.
// 관전은 공개 정보만, 전부 뷰는 항상.
bool view_knows(int view, uint8_t seen_before, uint8_t seen_after, bool pub_before, bool pub_after) {
  if (view == WX_VIEW_ALL) return true;
  if (view == WX_VIEW_SPECTATOR) return pub_before || pub_after;
  return (((seen_before | seen_after) >> view) & 1u) != 0;
}

bool view_knows_now(const State& s, int view, CardIdx c) {
  const uint8_t seen = static_cast<uint8_t>(s.viewers(c) | s.cards.get(c).known_by);
  const bool pub = s.viewers(c) == 0b11;
  return view_knows(view, seen, seen, pub, pub);
}
}  // namespace

template <class F>
void Duel::emit(uint16_t type, F&& body) {
  for (int v = 0; v < 4; ++v) emit_to(v, type, [&](auto& w) { body(w, v); });
}

template <class F>
void Duel::emit_to(int view, uint16_t type, F&& body) {
  auto& b = outbox_[view];
  const size_t start = b.size();
  Writer w{b};
  w.u32(0);
  w.u16(type);
  body(w);
  const uint32_t size = static_cast<uint32_t>(b.size() - start - 4);
  for (int i = 0; i < 4; ++i) b[start + i] = static_cast<uint8_t>(size >> (8 * i));
}

uint32_t Duel::handle(CardIdx c) const { return c == kNoCard ? 0 : state.cards.get(c).oid; }

void Duel::msg_coin(PlayerId p) {
  emit(WX_MSG_COIN, [&](Writer& w, int) {
    w.u8(p);
    w.u8(static_cast<uint8_t>(players[p].coins));
  });
}

void Duel::msg_marker(ZoneId z, uint8_t kind) {
  const Zone& zone = state.zones.get(z);
  emit(WX_MSG_MARKER, [&](Writer& w, int) {
    w.u16(static_cast<uint16_t>(z));
    w.u8(kind);
    w.u8((kind == 1 ? zone.gate : zone.virus) ? 1 : 0);
  });
}

void Duel::msg_reset() {
  emit(WX_MSG_RESET, [](Writer&, int) {});
}

void Duel::msg_zones() {
  emit(WX_MSG_ZONES, [&](Writer& w, int) {
    w.u16(static_cast<uint16_t>(state.zones.size()));
    for (ZoneId z = 0; z < state.zones.size(); ++z) {
      const Zone& zone = state.zones.get(z);
      w.u16(z);
      w.u8(zone.owner);
      w.u8(static_cast<uint8_t>(zone.kind));
      w.u8(zone.absent ? 1 : 0);
      w.u8(static_cast<uint8_t>(std::min<size_t>(zone.name.size(), 255)));
      w.str(zone.name, 255);
      w.u8(static_cast<uint8_t>(zone.adjacent.size()));
      for (ZoneId a : zone.adjacent) w.u16(a);
      w.u16(zone.front);
    }
  });
}

void Duel::msg_start() {
  emit(WX_MSG_START, [&](Writer& w, int) { w.u8(first_player); });
}

void Duel::msg_turn() {
  emit(WX_MSG_NEW_TURN, [&](Writer& w, int) {
    w.u8(turn_player);
    w.u32(turn_count);
  });
}

void Duel::enter_phase(uint32_t p) {
  phase = p;
  emit(WX_MSG_NEW_PHASE, [&](Writer& w, int) { w.u32(p); });
}

void Duel::on_move(const MoveRecord& r) {
  const Cid cid = state.cards.get(r.card).cid;
  const uint16_t print = state.cards.get(r.card).print;
  const bool face = state.cards.get(r.card).face_up;
  emit(WX_MSG_MOVE, [&](Writer& w, int v) {
    const bool knows = view_knows(v, r.seen_before, r.seen_after, r.public_before, r.public_after);
    w.u32(r.old_oid);
    w.u32(r.new_oid);
    w.u32(knows ? cid : 0);
    w.u16(r.from);
    w.u16(r.to);
    w.u8(r.pos == Pos::Bottom ? 1 : 0);
    w.u8(static_cast<uint8_t>(r.kind));
    w.u32(handle(r.host));
    w.u8(face ? 1 : 0);
    w.u16(knows ? print : 0);
  });
}

void Duel::on_shuffle(ZoneId z) {
  const auto& cards = state.zones.get(z).cards;
  emit(WX_MSG_SHUFFLE, [&](Writer& w, int) {
    w.u16(z);
    w.u16(static_cast<uint16_t>(cards.size()));
    for (CardIdx c : cards) w.u32(handle(c));
  });
}

void Duel::set_flags(CardIdx c, uint32_t flags) {
  if (state.cards.get(c).flags == flags) return;
  state.cards.get(c).flags = flags;
  emit(WX_MSG_FLAGS, [&](Writer& w, int) {
    w.u32(handle(c));
    w.u32(flags);
  });
}

// everyone: 모두에게 공개한다(관전자 포함). 아니면 지금 아는 쪽에만 cid를 보낸다
void Duel::msg_reveal(CardIdx c, bool everyone) {
  const Cid cid = state.cards.get(c).cid;
  emit(WX_MSG_REVEAL, [&](Writer& w, int v) {
    const bool knows = everyone || view_knows_now(state, v, c);
    w.u32(handle(c));
    w.u32(knows ? cid : 0);
    w.u16(knows ? state.cards.get(c).print : 0);
  });
}

void Duel::msg_attack(CardIdx c) {
  emit(WX_MSG_ATTACK, [&](Writer& w, int) { w.u32(handle(c)); });
}

void Duel::msg_battle(CardIdx a, CardIdx d, int32_t ap, int32_t dp) {
  emit(WX_MSG_BATTLE, [&](Writer& w, int) {
    w.u32(handle(a));
    w.u32(handle(d));
    w.i32(ap);
    w.i32(dp);
  });
}

void Duel::msg_player(uint16_t type, PlayerId p) {
  emit(type, [&](Writer& w, int) { w.u8(p); });
}

void Duel::msg_trigger(const Pending& t) {
  emit(WX_MSG_TRIGGER, [&](Writer& w, int v) {
    w.u8(t.player);
    w.u32(handle(t.handler));
    // 설명 번호에는 cid가 들어 있다(cid × 32 + slot). 그 카드를 모르는 쪽에는 보내지 않는다
    w.u32(t.handler == kNoCard || view_knows_now(state, v, t.handler) ? desc_of(t.effect) : 0);
  });
}

void Duel::msg_request() {
  const Request& r = *pending_req_;
  for (int v = 0; v < 4; ++v) {
    if (v != r.player && v != WX_VIEW_ALL) {
      emit_to(v, WX_MSG_WAITING, [&](Writer& w) { w.u8(r.player); });
      continue;
    }
    emit_to(v, WX_MSG_REQUEST, [&](Writer& w) {
      w.u8(static_cast<uint8_t>(r.type));
      w.u8(r.player);
      w.u32(r.hint);
      w.u32(r.min);
      w.u32(r.max);
      w.u16(static_cast<uint16_t>(r.options.size()));
      size_t i = 0;
      for (uint32_t o : r.options) {
        if (r.type == ReqType::SelectCards) {
          w.u32(handle(o));
        } else if (r.type == ReqType::SelectAction) {
          const Action& a = actions_[o];
          w.u8(static_cast<uint8_t>(a.kind));
          w.u32(handle(a.card));
          w.u16(a.zone);
          w.u32(a.effect);
          w.u32(desc_of(a.effect));
        } else {
          w.u32(o);
          w.u32(r.option_cards.size() > i ? handle(r.option_cards[i]) : 0);
          w.u32(r.option_descs.size() > i ? r.option_descs[i] : 0);
        }
        ++i;
      }
      w.u8(r.cancelable ? 1 : 0);
      w.u32(r.source != kNoCard ? handle(r.source) : 0);
      w.u32(r.source_desc);
    });
  }
}

void Duel::msg_retry(PlayerId p, const std::string& why) {
  for (int v : {static_cast<int>(p), static_cast<int>(WX_VIEW_ALL)})
    emit_to(v, WX_MSG_RETRY, [&](Writer& w) {
      w.u8(p);
      w.u16(static_cast<uint16_t>(std::min<size_t>(why.size(), 0xFFFF)));
      w.str(why, 0xFFFF);
    });
}

std::vector<uint8_t> Duel::take_messages(int view) { return std::exchange(outbox_[view], {}); }

}  // namespace wx
