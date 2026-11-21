-- 3c-2 Lua API: 덱 N번째, 숫자 선언, 공개, 손패 상한, 시그니 재배치, 덱 이동 이벤트·집계, アタックできない, 순서 지정

local function base(t)
  t:lrig(1, 3, 9, {"ウムル"}, COLOR_BLUE)
  t:signi(100, 1000)
  t:start()
  t:put(1, 0, "lrig_center")
  t:put(1, 1, "lrig_center")
end

local function arts(t, cid, op, timing)
  t:card{cid = cid, type = TYPE_ARTS, timing = timing or TIMING_MAIN}
  t:script(cid, ([[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp) %s end)
  c:RegisterEffect(e1)
end
]]):format(op))
end

local function use(t, card)
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_USE, card)))
end

-- ── 덱 위치 ──

local TO_THIRD = [[
for c in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do Duel.SendToDeckPosition(c,3) end
]]

case("deck: 상대 시그니를 덱 위에서 세 번째에", "WDK09-011 【出】, WDK09-012", function(t)
  base(t)
  arts(t, 60, TO_THIRD)
  local a = t:put(60, 0, "lrig_deck")
  t:fill(100, 0, "main_deck", 5)
  t:fill(100, 1, "main_deck", 5)
  local target = t:put(100, 1, "signi_center")
  use(t, a)
  t:expect(t:wait(HINT_MAIN))
  local deck = t:cards(1, "main_deck")
  t:expect(#deck == 6 and deck[#deck - 2] == target)
end)

case("deck: 덱이 1장이면 맨 아래에", "WDK09-011 FAQ 1, WDK09-012 FAQ 1", function(t)
  base(t)
  arts(t, 60, TO_THIRD)
  local a = t:put(60, 0, "lrig_deck")
  t:fill(100, 0, "main_deck", 5)
  t:put(100, 1, "main_deck")
  local target = t:put(100, 1, "signi_center")
  use(t, a)
  t:expect(t:wait(HINT_MAIN))
  local deck = t:cards(1, "main_deck")
  t:expect(#deck == 2 and deck[1] == target)
end)

-- ── 숫자 선언·공개 ──

case("declare: 숫자 하나를 선언한다", "WDK09-011 【自】", function(t)
  base(t)
  arts(t, 60, "DECLARED = Duel.AnnounceNumber(tp,0,5)")
  local a = t:put(60, 0, "lrig_deck")
  t:fill(100, 0, "main_deck", 5)
  t:fill(100, 1, "main_deck", 5)
  use(t, a)
  t:expect(t:wait(HINT_DECLARE))
  t:expect(#t:request().options == 6 and t:request().options[1] == 0)
  t:expect(t:answer(3))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:global("DECLARED") == 3)
end)

case("reveal: 덱 맨 위를 공개하면 양쪽이 보고, 덱 맨 위에 그대로 남는다", "WDK09-001 FAQ 2", function(t)
  base(t)
  arts(t, 60, "Duel.RevealCards(Duel.GetDecktopGroup(1-tp,1))")
  local a = t:put(60, 0, "lrig_deck")
  t:fill(100, 0, "main_deck", 5)
  t:fill(100, 1, "main_deck", 4)
  local top = t:put(100, 1, "main_deck")
  t:expect(not t:can_see(0, top))
  use(t, a)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:can_see(0, top) and t:can_see(1, top) and t:cards(1, "main_deck")[5] == top)
end)

-- ── 손패 상한 ──

case("hand: 상대 손패 상한 -1이면 엔드 페이즈에 5장까지 버린다", "WDK09-009 FAQ 1", function(t)
  base(t)
  t:card{cid = 50, type = TYPE_KEY}
  t:script(50, [[
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_UPDATE_HAND_LIMIT)
  e1:SetRange(LOCATION_KEY)
  e1:SetTargetRange(0,1)
  e1:SetValue(-1)
  c:RegisterEffect(e1)
end
]])
  t:put(50, 0, "key")
  t:fill(100, 0, "main_deck", 5)
  t:fill(100, 1, "main_deck", 5)
  t:fill(100, 1, "hand", 6)
  t:expect(t:hand_limit(1) == 5 and t:hand_limit(0) == 6)
  t:begin(1, PHASE_END)
  t:expect(t:wait(HINT_DISCARD))
  t:expect(t:request().min == 1, "6장 → 5장")
end)

-- ── 시그니 재배치 ──

case("move: 시그니를 같은 주인의 빈 시그니 존으로. 같은 객체, 채워진 존·상대 존은 안 된다", "WDK09-015 FAQ 2·3", function(t)
  base(t)
  arts(t, 60, [[
local c=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):GetFirst()
local z=Duel.GetSigniZones(tp)
local zo=Duel.GetSigniZones(1-tp)
R1 = Duel.MoveSigni(c,z[2])
R2 = Duel.MoveSigni(c,z[3])
R3 = Duel.MoveSigni(c,zo[1])
]])
  local a = t:put(60, 0, "lrig_deck")
  t:fill(100, 0, "main_deck", 5)
  t:fill(100, 1, "main_deck", 5)
  local s = t:put(100, 0, "signi_left")
  t:put(100, 0, "signi_right")
  local oid = t:oid(s)
  use(t, a)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:global("R1") == true and t:is_in(s, 0, "signi_center") and t:oid(s) == oid)
  t:expect(t:global("R2") == false, "채워진 존")
  t:expect(t:global("R3") == false, "상대 존")
end)

-- ── 덱 이동 이벤트·집계 ──

local WATCH = [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_MOVED_TO_DECK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
    if rp~=tp then return false end
    for c in eg:Iter() do if c:GetOwner()~=tp then return true end end
    return false
  end)
  e1:SetOperation(function(e,tp) FIRED = (FIRED or 0) + 1 end)
  c:RegisterEffect(e1)
end
]]

case("todeck: 효과 하나로 2장이 덱으로 가도 「移動したとき」는 한 번, 턴 집계는 2장", "WDK09-013 【自】, WDK09-014", function(t)
  base(t)
  t:signi(110, 1000)
  t:script(110, WATCH)
  t:put(110, 0, "signi_center")
  arts(t, 60, "Duel.SendToDeckBottom(Duel.GetMatchingGroup(nil,tp,0,LOCATION_TRASH,nil),false) COUNT = Duel.GetDeckMovedCount(tp)")
  local a = t:put(60, 0, "lrig_deck")
  t:fill(100, 0, "main_deck", 5)
  t:fill(100, 1, "main_deck", 5)
  t:fill(100, 1, "trash", 2)
  use(t, a)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:global("FIRED") == 1, "한 번만")
  t:expect(t:global("COUNT") == 2)
end)

case("todeck: 덱에서 덱으로의 이동은 해당하지 않는다", "WDK09-013 FAQ 2", function(t)
  base(t)
  t:signi(110, 1000)
  t:script(110, WATCH)
  t:put(110, 0, "signi_center")
  arts(t, 60, "Duel.SendToDeckBottom(Duel.GetDecktopGroup(1-tp,2),false) COUNT = Duel.GetDeckMovedCount(tp)")
  local a = t:put(60, 0, "lrig_deck")
  t:fill(100, 0, "main_deck", 5)
  t:fill(100, 1, "main_deck", 5)
  use(t, a)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:global("FIRED") == nil and t:global("COUNT") == 0)
end)

-- ── アタックできない ──

case("attack: 「アタックできない」를 얻은 시그니는 어택 후보가 아니다", "WDK09-009 (エクシード２：…「【常】：アタックできない。」を得る)", function(t)
  base(t)
  t:fill(100, 0, "main_deck", 5)
  t:fill(100, 1, "main_deck", 5)
  t:fill(100, 1, "life_cloth", 3)
  local a = t:put(100, 0, "signi_left")
  local b = t:put(100, 0, "signi_right")
  t:grant(a, EFFECT_CANNOT_ATTACK, 0, 1)
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == b)
end)

case("attack: 【ゲート】 존의 시그니는 그 턴 어택할 수 없다. 나중에 그 존에 나온 시그니도", "WDK09-001 FAQ 4", function(t)
  base(t)
  t:fill(100, 0, "main_deck", 5)
  t:fill(100, 1, "main_deck", 5)
  t:fill(100, 1, "life_cloth", 3)
  t:place_gate(0, "signi_left")
  -- 「このターン、対戦相手は【ゲート】があるシグニゾーンにあるシグニでアタックできない」를 상대(1)가 건 것처럼
  t:field(EFFECT_CANNOT_ATTACK, 0, 1, 0, LOCATION_SIGNI, RESET_PHASE | PHASE_END)
  -- 위 t:field는 범위 전체라 게이트 필터는 스크립트(3c-3)에서 확인한다. 여기서는 FIELD 금지가 듣는지만
  local a = t:put(100, 0, "signi_left")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_LRIG) or true)
  t:expect(not t:saw(HINT_ATTACK_SIGNI), "어택할 시그니가 없다")
  t:expect(t:flags(a) & CF_DOWN == 0)
end)

-- ── 순서 지정 ──

case("order: 덱 아래에 놓을 순서를 상대가 정한다", "WDK09-013 【出】(置く順番は対戦相手が選ぶ)", function(t)
  base(t)
  arts(t, 60, "Duel.SendToDeckBottom(Duel.SelectOrder(1-tp,Duel.GetMatchingGroup(nil,tp,0,LOCATION_TRASH,nil)),false)")
  local a = t:put(60, 0, "lrig_deck")
  t:fill(100, 0, "main_deck", 5)
  t:fill(100, 1, "main_deck", 3)
  local x, y = t:put(100, 1, "trash"), t:put(100, 1, "trash")
  use(t, a)
  t:expect(t:wait(HINT_ORDER))
  t:expect(t:request().player == 1)
  t:expect(t:answer(y, x))
  t:expect(t:wait(HINT_MAIN))
  local deck = t:cards(1, "main_deck")
  t:expect(deck[1] == x and deck[2] == y, "나중에 놓은 것이 맨 아래")
end)

case("shuffle: 「デッキに加えてシャッフル」은 옮긴 카드가 없어도 섞는다", "WDK09-001 FAQ 6", function(t)
  base(t)
  arts(t, 60, "Duel.SendToDeckShuffle(Group.CreateGroup(),1-tp)")
  local a = t:put(60, 0, "lrig_deck")
  t:fill(100, 0, "main_deck", 5)
  t:fill(100, 1, "main_deck", 5)
  local before = t:oid(t:cards(1, "main_deck")[1])
  use(t, a)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:oid(t:cards(1, "main_deck")[1]) ~= before, "셔플하면 handle이 새로 나온다")
end)
