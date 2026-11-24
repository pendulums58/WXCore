#include "field_model.h"

#include <algorithm>

namespace wxframe {

namespace {

struct In {
  const uint8_t* p;
  size_t n, pos = 0;
  uint32_t get(int bytes) {
    uint32_t v = 0;
    for (int i = 0; i < bytes && pos < n; ++i) v |= static_cast<uint32_t>(p[pos++]) << (8 * i);
    return v;
  }
  std::string str(size_t len) {
    std::string s;
    for (size_t i = 0; i < len && pos < n; ++i) s += static_cast<char>(p[pos++]);
    return s;
  }
};

struct Out {
  std::vector<uint8_t> b;
  void put(uint32_t v, int bytes) {
    for (int i = 0; i < bytes; ++i) b.push_back(static_cast<uint8_t>(v >> (8 * i)));
  }
};

// UPDATE 안의 카드 한 장. wx_card_info 필드 순서대로
void put_card(Out& o, const wx_card_info& c) {
  o.put(c.handle, 4);
  o.put(c.cid, 4);
  o.put(c.known, 1);
  o.put(c.owner, 1);
  o.put(c.controller, 1);
  o.put(c.face_up, 1);
  o.put(c.zone, 2);
  o.put(c.host, 4);
  o.put(c.flags, 4);
  o.put(c.type, 4);
  o.put(c.color, 1);
  o.put(static_cast<uint32_t>(c.level), 4);
  o.put(static_cast<uint32_t>(c.limit), 4);
  o.put(static_cast<uint32_t>(c.power), 4);
  o.put(c.keywords, 4);
  o.put(c.n_under, 2);
  o.put(c.n_attached, 2);
  o.put(c.print, 2);
}

wx_card_info get_card(In& r) {
  wx_card_info c{};
  c.handle = r.get(4);
  c.cid = r.get(4);
  c.known = static_cast<uint8_t>(r.get(1));
  c.owner = static_cast<uint8_t>(r.get(1));
  c.controller = static_cast<uint8_t>(r.get(1));
  c.face_up = static_cast<uint8_t>(r.get(1));
  c.zone = static_cast<uint16_t>(r.get(2));
  c.host = r.get(4);
  c.flags = r.get(4);
  c.type = r.get(4);
  c.color = static_cast<uint8_t>(r.get(1));
  c.level = static_cast<int32_t>(r.get(4));
  c.limit = static_cast<int32_t>(r.get(4));
  c.power = static_cast<int32_t>(r.get(4));
  c.keywords = r.get(4);
  c.n_under = static_cast<uint16_t>(r.get(2));
  c.n_attached = static_cast<uint16_t>(r.get(2));
  c.print = static_cast<uint16_t>(r.get(2));
  return c;
}

bool same(const wx_card_info& a, const wx_card_info& b) {
  return a.handle == b.handle && a.cid == b.cid && a.known == b.known && a.owner == b.owner && a.controller == b.controller &&
         a.face_up == b.face_up && a.zone == b.zone && a.host == b.host && a.flags == b.flags && a.type == b.type &&
         a.color == b.color && a.level == b.level && a.limit == b.limit && a.power == b.power && a.keywords == b.keywords &&
         a.n_under == b.n_under && a.n_attached == b.n_attached && a.print == b.print;
}

bool same_granted(const std::vector<wx_granted_info>& a, const std::vector<wx_granted_info>& b) {
  if (a.size() != b.size()) return false;
  for (size_t i = 0; i < a.size(); ++i)
    if (a[i].desc != b[i].desc || a[i].keyword != b[i].keyword || a[i].source_cid != b[i].source_cid) return false;
  return true;
}

const std::vector<uint32_t> kEmpty;
const std::vector<wx_granted_info> kNoGranted;

}  // namespace

void FieldModel::reset() {
  zones_.clear();
  zone_cards_.clear();
  markers_.clear();
  cards_.clear();
  granted_.clear();
  game_ = wx_game_info{};
  game_.winner = 0xFF;
  players_[0] = players_[1] = wx_player_info{};
}

const wx_card_info* FieldModel::card(uint32_t handle) const {
  auto it = cards_.find(handle);
  return it == cards_.end() ? nullptr : &it->second;
}

const std::vector<wx_granted_info>& FieldModel::granted(uint32_t handle) const {
  auto it = granted_.find(handle);
  return it == granted_.end() ? kNoGranted : it->second;
}

const std::vector<uint32_t>& FieldModel::zone(uint16_t z) const { return z < zone_cards_.size() ? zone_cards_[z] : kEmpty; }

std::vector<uint32_t> FieldModel::hosted(uint32_t host, bool attached) const {
  std::vector<uint32_t> out;
  for (const auto& [h, c] : cards_)  // handle은 놓인 순서대로 커진다
    if (host && c.host == host && ((c.flags & kAttachedFlag) != 0) == attached) out.push_back(h);
  return out;
}

uint32_t FieldModel::trap(uint16_t z) const {
  for (const auto& [h, c] : cards_)
    if (c.zone == z && (c.flags & kSetFlag) && !c.host) return h;
  return 0;
}

uint32_t FieldModel::seed(uint16_t z) const {
  for (const auto& [h, c] : cards_)
    if (c.zone == z && (c.flags & kSeedFlag) && !c.host) return h;
  return 0;
}

void FieldModel::remove_handle(uint32_t h) {
  auto it = cards_.find(h);
  if (it == cards_.end()) return;
  const uint16_t z = it->second.zone;
  if (!it->second.host && z < zone_cards_.size()) std::erase(zone_cards_[z], h);
  cards_.erase(it);
  granted_.erase(h);
}

void FieldModel::apply(const uint8_t* m, size_t len) {
  In r{m, len, 4};
  const uint32_t type = r.get(2);
  switch (type) {
    case WX_MSG_RESET: reset(); break;
    case WX_MSG_ZONES: {
      const uint32_t n = r.get(2);
      zones_.clear();
      for (uint32_t i = 0; i < n; ++i) {
        ZoneMeta z;
        z.id = static_cast<uint16_t>(r.get(2));
        z.owner = static_cast<uint8_t>(r.get(1));
        r.get(1);  // kind
        r.get(1);  // absent
        z.name = r.str(r.get(1));
        const uint32_t adj = r.get(1);
        for (uint32_t k = 0; k < adj; ++k) r.get(2);
        r.get(2);  // front
        zones_.push_back(std::move(z));
      }
      zone_cards_.assign(zones_.size(), {});
      markers_.assign(zones_.size(), 0);
      break;
    }
    case WX_MSG_NEW_TURN:
      game_.turn_player = static_cast<uint8_t>(r.get(1));
      game_.turn_count = r.get(4);
      break;
    case WX_MSG_NEW_PHASE: game_.phase = r.get(4); break;
    case WX_MSG_WIN:
      game_.ended = 1;
      game_.winner = static_cast<uint8_t>(r.get(1));
      break;
    case WX_MSG_COIN: {
      const uint32_t p = r.get(1);
      players_[p & 1].coins = r.get(1);
      break;
    }
    case WX_MSG_MARKER: {
      const uint32_t z = r.get(2), kind = r.get(1), n = r.get(1);
      const uint8_t bit = kind == 1 ? 1 : kind == 2 ? 2 : 0;
      if (z < markers_.size()) markers_[z] = static_cast<uint8_t>(n ? markers_[z] | bit : markers_[z] & ~bit);
      break;
    }
    case WX_MSG_FLAGS: {
      const uint32_t h = r.get(4);
      if (auto it = cards_.find(h); it != cards_.end()) it->second.flags = r.get(4);
      break;
    }
    case WX_MSG_REVEAL: {
      const uint32_t h = r.get(4), cid = r.get(4);
      const uint16_t print = static_cast<uint16_t>(r.get(2));
      if (auto it = cards_.find(h); it != cards_.end() && cid) {
        it->second.cid = cid;
        it->second.print = print;
        it->second.known = 1;
      }
      break;
    }
    case WX_MSG_MOVE: {
      const uint32_t old_h = r.get(4), new_h = r.get(4), cid = r.get(4);
      const uint16_t from = static_cast<uint16_t>(r.get(2)), to = static_cast<uint16_t>(r.get(2));
      const bool bottom = r.get(1) != 0;
      const uint32_t kind = r.get(1), host = r.get(4);
      const bool face = r.get(1) != 0;
      const uint16_t print = static_cast<uint16_t>(r.get(2));
      wx_card_info c{};
      if (const wx_card_info* old = card(old_h)) c = *old;  // 주인 등은 그대로 이어받는다
      remove_handle(old_h);
      (void)from;
      c.handle = new_h;
      c.cid = cid;
      c.print = print;
      c.known = cid != 0;
      c.face_up = face;
      c.flags = 0;
      if (kind == 4 || kind == 5) {  // 【トラップ】·【シード】: 존 목록이 아니라 세트 층
        c.host = 0;
        c.zone = to;
        c.flags = kind == 5 ? kSeedFlag : kSetFlag;
      } else if (kind == 1 || kind == 2) {  // 아래에 놓기·붙이기: 존 목록이 아니라 호스트에 딸린다
        c.host = host;
        if (kind == 2) c.flags = kAttachedFlag;
        const wx_card_info* h = card(host);
        c.zone = h ? h->zone : to;
      } else {
        c.host = 0;
        c.zone = to;
        if (to < zone_cards_.size()) {
          auto& list = zone_cards_[to];
          if (bottom) list.insert(list.begin(), new_h);
          else list.push_back(new_h);
          if (!old_h || from == 0xFFFF) c.owner = c.controller = zones_[to].owner;  // 처음 만들어진 카드
        }
      }
      cards_[new_h] = c;
      break;
    }
    case WX_MSG_SHUFFLE: {
      // 섞으면 handle을 새로 주고 인지 기록도 지운다(코어와 같음)
      const uint16_t z = static_cast<uint16_t>(r.get(2));
      const uint32_t n = r.get(2);
      std::vector<wx_card_info> olds;
      if (z < zone_cards_.size())
        for (uint32_t h : zone_cards_[z])
          if (const wx_card_info* c = card(h)) olds.push_back(*c);
      if (z < zone_cards_.size())
        for (uint32_t h : std::vector<uint32_t>(zone_cards_[z])) remove_handle(h);
      for (uint32_t i = 0; i < n; ++i) {
        wx_card_info c = i < olds.size() ? olds[i] : wx_card_info{};
        c.handle = r.get(4);
        c.cid = 0;
        c.known = 0;
        c.zone = z;
        c.host = 0;
        if (z < zone_cards_.size()) zone_cards_[z].push_back(c.handle);
        cards_[c.handle] = c;
      }
      break;
    }
    case kMsgUpdate: parse_update(m + r.pos, len - r.pos); break;
    default: break;
  }
}

// UPDATE 본문:
//   u16 고친 존 수, (u16 존, u16 장 수, u32 handle...)...
//   u16 게이트가 바뀐 존 수, (u16 존, u8 게이트)...
//   u16 카드 수, 카드...
//   플레이어 2명 (u32 코인, i32 패 상한), 게임 (u8 턴 플레이어, u32 턴 수, u32 페이즈)
//   u16 부여 목록이 바뀐 카드 수, (u32 handle, u8 개수, (u32 desc, u32 키워드, u32 부여한 카드 cid)...)...
void FieldModel::parse_update(const uint8_t* p, size_t n) {
  In r{p, n};
  const uint32_t nz = r.get(2);
  for (uint32_t i = 0; i < nz; ++i) {
    const uint16_t z = static_cast<uint16_t>(r.get(2));
    const uint32_t k = r.get(2);
    std::vector<uint32_t> list;
    for (uint32_t j = 0; j < k; ++j) list.push_back(r.get(4));
    if (z < zone_cards_.size()) {
      // 목록에서 빠진 카드는 지운다(새 카드 값은 아래 카드 목록으로 온다)
      for (uint32_t h : zone_cards_[z])
        if (std::find(list.begin(), list.end(), h) == list.end()) {
          cards_.erase(h);
          granted_.erase(h);
        }
      zone_cards_[z] = std::move(list);
    }
  }
  const uint32_t ng = r.get(2);
  for (uint32_t i = 0; i < ng; ++i) {
    const uint16_t z = static_cast<uint16_t>(r.get(2));
    const uint8_t g = static_cast<uint8_t>(r.get(1));
    if (z < markers_.size()) markers_[z] = g;
  }
  const uint32_t nc = r.get(2);
  for (uint32_t i = 0; i < nc; ++i) {
    const wx_card_info c = get_card(r);
    cards_[c.handle] = c;
  }
  for (auto& pl : players_) {
    pl.coins = r.get(4);
    pl.hand_limit = static_cast<int32_t>(r.get(4));
  }
  game_.turn_player = static_cast<uint8_t>(r.get(1));
  game_.turn_count = r.get(4);
  game_.phase = r.get(4);
  const uint32_t ngr = r.get(2);
  for (uint32_t i = 0; i < ngr; ++i) {
    const uint32_t h = r.get(4), k = r.get(1);
    std::vector<wx_granted_info> list(k);
    for (auto& g : list) {
      g.desc = r.get(4);
      g.keyword = r.get(4);
      g.source_cid = r.get(4);
    }
    if (list.empty()) granted_.erase(h);
    else granted_[h] = std::move(list);
  }
}

std::vector<uint8_t> FieldModel::make_update(wx_duel* duel, uint8_t view, std::vector<uint16_t>* zone_fixes) const {
  Out zones, gates, cards, grants;
  uint32_t nz = 0, ng = 0, nc = 0, ngr = 0;
  auto check_card = [&](uint32_t h) {
    wx_card_info now{};
    if (wx_query_card(duel, view, h, &now) != WX_OK) return;
    std::vector<wx_granted_info> gl(wx_query_granted(duel, view, h, nullptr, 0));
    wx_query_granted(duel, view, h, gl.data(), gl.size());
    if (!same_granted(gl, granted(h))) {
      grants.put(h, 4);
      grants.put(static_cast<uint32_t>(std::min<size_t>(gl.size(), 255)), 1);
      for (size_t i = 0; i < gl.size() && i < 255; ++i) {
        grants.put(gl[i].desc, 4);
        grants.put(gl[i].keyword, 4);
        grants.put(gl[i].source_cid, 4);
      }
      ++ngr;
    }
    const wx_card_info* mine = card(h);
    if (mine && same(*mine, now)) return;
    put_card(cards, now);
    ++nc;
  };
  const size_t count = wx_zone_count(duel);
  for (uint16_t z = 0; z < count; ++z) {
    std::vector<uint32_t> list(wx_query_zone(duel, view, z, nullptr, 0));
    wx_query_zone(duel, view, z, list.data(), list.size());
    if (list != zone(z)) {
      zones.put(z, 2);
      zones.put(static_cast<uint32_t>(list.size()), 2);
      for (uint32_t h : list) zones.put(h, 4);
      ++nz;
      if (zone_fixes) zone_fixes->push_back(z);
    }
    uint8_t g = 0;
    wx_query_zone_info(duel, z, nullptr, 0, nullptr, &g);
    if (g != markers(z)) {
      gates.put(z, 2);
      gates.put(g, 1);
      ++ng;
    }
    if (const uint32_t s = wx_query_set(duel, z)) check_card(s);
    if (const uint32_t s = wx_query_seed(duel, z)) check_card(s);
    for (uint32_t h : list) {
      check_card(h);
      // 아래 카드(엑시드로 고르는 등 장에서 안 보이는 후보)
      std::vector<uint32_t> under(wx_query_under(duel, view, h, nullptr, 0));
      wx_query_under(duel, view, h, under.data(), under.size());
      for (uint32_t u : under) check_card(u);
      std::vector<uint32_t> attached(wx_query_attached(duel, view, h, nullptr, 0));
      wx_query_attached(duel, view, h, attached.data(), attached.size());
      for (uint32_t a : attached) check_card(a);
    }
  }
  wx_player_info pl[2]{};
  wx_query_player(duel, 0, &pl[0]);
  wx_query_player(duel, 1, &pl[1]);
  wx_game_info g{};
  wx_query_game(duel, &g);
  const bool players_same = pl[0].coins == players_[0].coins && pl[0].hand_limit == players_[0].hand_limit &&
                            pl[1].coins == players_[1].coins && pl[1].hand_limit == players_[1].hand_limit;
  const bool game_same = g.turn_player == game_.turn_player && g.turn_count == game_.turn_count && g.phase == game_.phase;
  if (!nz && !ng && !nc && !ngr && players_same && game_same) return {};

  Out o;
  o.put(0, 4);  // 크기(아래에서 채운다)
  o.put(kMsgUpdate, 2);
  o.put(nz, 2);
  o.b.insert(o.b.end(), zones.b.begin(), zones.b.end());
  o.put(ng, 2);
  o.b.insert(o.b.end(), gates.b.begin(), gates.b.end());
  o.put(nc, 2);
  o.b.insert(o.b.end(), cards.b.begin(), cards.b.end());
  for (const auto& p : pl) {
    o.put(p.coins, 4);
    o.put(static_cast<uint32_t>(p.hand_limit), 4);
  }
  o.put(g.turn_player, 1);
  o.put(g.turn_count, 4);
  o.put(g.phase, 4);
  o.put(ngr, 2);
  o.b.insert(o.b.end(), grants.b.begin(), grants.b.end());
  const uint32_t size = static_cast<uint32_t>(o.b.size() - 4);
  for (int i = 0; i < 4; ++i) o.b[i] = static_cast<uint8_t>(size >> (8 * i));
  return o.b;
}

}  // namespace wxframe
