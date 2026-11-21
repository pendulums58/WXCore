-- 3b-2 Lua API: 【出】 코스트, 모드 선택, 《ターン1回》, 다운·동결, 버리기·선택, 덱 위 보기·장에 내기, 키워드

local function base(t, opts)
  t:lrig(1, 3, 9, {"タマ"})
  t:signi(100, 1000)
  t:start(opts)
  t:fill(100, 0, "main_deck", 10)
  t:fill(100, 1, "main_deck", 10)
  t:put(1, 0, "lrig_center")
  t:put(1, 1, "lrig_center")
end

local function play(t, card, zone)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_PLAY, card, zone or "signi_center")))
end

-- ── 【出】 코스트 ──

local ON_PLAY_BLUE = [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{U}")
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
]]

case("cost: 【出】《青》 — 낼 수 있으면 낼지 묻고, 내면 발동", "WXDi-D01-010 (【出】能力の：の左側はコスト)", function(t)
  base(t)
  t:signi(300, 1000)
  t:script(300, ON_PLAY_BLUE)
  t:signi(101, 1000, COLOR_BLUE)
  local s = t:put(300, 0, "hand")
  local blue = t:put(101, 0, "ena")
  t:begin(0, PHASE_MAIN)
  play(t, s)
  t:expect(t:wait(HINT_USE_TRIGGER), "코스트가 있으면 임의")
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(blue))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1 and t:is_in(blue, 0, "trash"))
end)

case("cost: 【出】 코스트를 낼 수 없으면 묻지 않는다", "WXDi-D01-015 FAQ 1", function(t)
  base(t)
  t:signi(300, 1000)
  t:script(300, ON_PLAY_BLUE)
  local s = t:put(300, 0, "hand")
  t:put(100, 0, "ena")  -- 백
  t:begin(0, PHASE_MAIN)
  play(t, s)
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_USE_TRIGGER))
  t:expect(t:count(0, "hand") == 0)
end)

local ON_PLAY_DISCARD2 = [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()>=2 end
    Duel.SendToTrash(Duel.SelectDiscard(tp,2,2),REASON_COST+REASON_DISCARD)
  end)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,2) end)
  c:RegisterEffect(e1)
end
]]

case("cost: 【出】手札を２枚捨てる — 1장뿐이면 1장도 못 버리고 발동하지 않는다", "WXDi-D01-015 FAQ 1", function(t)
  base(t)
  t:signi(300, 1000)
  t:script(300, ON_PLAY_DISCARD2)
  local s = t:put(300, 0, "hand")
  t:put(100, 0, "hand")
  t:begin(0, PHASE_MAIN)
  play(t, s)
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_USE_TRIGGER) and t:count(0, "hand") == 1)
end)

case("cost: 【出】手札を２枚捨てる — 2장이면 버리고 2장 뽑는다", "WXDi-D01-015", function(t)
  base(t)
  t:signi(300, 1000)
  t:script(300, ON_PLAY_DISCARD2)
  local s = t:put(300, 0, "hand")
  local h1 = t:put(100, 0, "hand")
  local h2 = t:put(100, 0, "hand")
  t:begin(0, PHASE_MAIN)
  play(t, s)
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_DISCARD))
  t:expect(t:answer(h1, h2))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(h1, 0, "trash") and t:is_in(h2, 0, "trash") and t:count(0, "hand") == 2)
end)

case("cost: 【出】 코스트를 내지 않기로 하면 발동하지 않는다", "WXDi-D01-010 (コストを支払わず発動しないことを選んでもよい)", function(t)
  base(t)
  t:signi(300, 1000)
  t:script(300, ON_PLAY_DISCARD2)
  local s = t:put(300, 0, "hand")
  t:fill(100, 0, "hand", 2)
  t:begin(0, PHASE_MAIN)
  play(t, s)
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(0))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 2 and t:count(0, "trash") == 0)
end)

-- ── 모드 선택 ──

local MODE_SPELL = [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    e:SetLabel(Duel.SelectOption(tp,"draw","charge"))
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
end
]]

case("mode: 「２つから１つを選ぶ」 — 고른 쪽만 처리한다", "WDK09-022, WXDi-D01-015 ライフバースト", function(t)
  base(t)
  t:card{cid = 400, type = TYPE_SPELL}
  t:script(400, MODE_SPELL)
  local sp = t:put(400, 0, "hand")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_MODE))
  local r = t:request()
  t:expect(#r.options == 2 and r.cancelable, "확정 전이라 취소 가능")
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "ena") == 1 and t:count(0, "hand") == 0)
end)

case("mode: 모드 선택 중 취소하면 처음으로", "설계: 확정 전 취소", function(t)
  base(t)
  t:card{cid = 400, type = TYPE_SPELL}
  t:script(400, MODE_SPELL)
  local sp = t:put(400, 0, "hand")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_MODE))
  t:expect(t:cancel())
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(sp, 0, "hand"))
end)

-- ── 《ターン1回》 ──

local ONCE = [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
]]

case("count: 《ターン1回》은 그 턴에 한 번, 다음 자기 턴에 다시", "용어집: ターン１回", function(t)
  base(t)
  t:signi(300, 1000)
  t:script(300, ONCE)
  local s = t:put(300, 0, "signi_center")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_ABILITY, s)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:action(ACT_ABILITY, s) == nil, "두 번째는 없다")
  -- 상대 턴을 지나 다음 자기 메인
  for _ = 1, 4 do
    t:expect(t:answer(t:action(ACT_END)))
    t:expect(t:wait(HINT_MAIN))
    if t:request().player == 0 then break end
  end
  t:expect(t:request().player == 0 and t:action(ACT_ABILITY, s) ~= nil, "다음 턴에 다시")
end)

case("count: 장을 떠났다 다시 나온 시그니는 새 객체라 다시 쓸 수 있다", "용어집: 領域(새 객체), 《ターン1回》", function(t)
  base(t)
  t:signi(300, 1000)
  t:script(300, ONCE)
  local s = t:put(300, 0, "signi_center")
  local other = t:put(100, 0, "hand")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_ABILITY, s)))
  t:expect(t:wait(HINT_MAIN))
  t:move(s, 0, "hand")
  t:move(s, 0, "signi_left")
  play(t, other, "signi_right")  -- 행동 목록을 다시 만들게 한다
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:action(ACT_ABILITY, s) ~= nil)
end)

-- ── 다운·동결 ──

local FREEZE_ARTS = [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(Card.IsSigni,tp,0,LOCATION_SZONE,1,nil) end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) Duel.Freeze(tc) end
  end)
  c:RegisterEffect(e1)
end
]]

case("freeze: 다운하고 동결한 시그니는 다음 업 페이즈에 업하지 않고, 그 끝에 동결이 풀린다", "용어집: 凍結, WXDi-D01-016 ライフバースト", function(t)
  base(t)
  t:card{cid = 401, type = TYPE_ARTS, timing = TIMING_MAIN}
  t:script(401, FREEZE_ARTS)
  local arts = t:put(401, 0, "lrig_deck")
  local target = t:put(100, 1, "signi_center")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(target))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:flags(target) & CF_DOWN ~= 0 and t:flags(target) & CF_FROZEN ~= 0)
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:request().player == 1)
  t:expect(t:flags(target) & CF_DOWN ~= 0, "업하지 않았다")
  t:expect(t:flags(target) & CF_FROZEN == 0, "업 페이즈 끝에 동결 해제")
end)

-- ── 선택·버리기 ──

case("select: 상대 패를 보지 않고 골라 버리게 한다", "WXDi-D01-016 (見ないで選び、捨てさせる)", function(t)
  base(t)
  t:card{cid = 401, type = TYPE_ARTS, timing = TIMING_MAIN}
  t:script(401, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD)
  end)
  c:RegisterEffect(e1)
end
]])
  local arts = t:put(401, 0, "lrig_deck")
  local h = t:put(100, 1, "hand")
  t:put(100, 1, "hand")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:request().player == 0 and #t:request().options == 2)
  t:expect(not t:can_see(0, h), "고르는 사람은 그 카드를 모른다")
  t:expect(t:answer(h))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(h, 1, "trash") and t:count(1, "hand") == 1)
end)

-- ── 덱 위 보기·장에 내기 ──

local LOOK_AND_PUT = [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    Duel.ConfirmCards(tp,g)
    SAW = 0
    for x in g:Iter() do SAW = SAW + 1 end
    local c=Duel.SelectCards(tp,g:Filter(Card.IsSigni,nil),0,1):GetFirst()
    PUT = c and Duel.PutOnField(c,tp) or false
    local rest=Group.CreateGroup()
    for x in g:Iter() do if x~=c then rest:AddCard(x) end end
    Duel.SendToDeckBottom(rest,true)
  end)
  c:RegisterEffect(e1)
end
]]

local function look_setup(t, limit)
  t:lrig(1, 3, limit or 9, {"タマ"})
  t:signi(100, 1000)
  t:card{cid = 402, type = TYPE_ARTS, timing = TIMING_MAIN}
  t:script(402, LOOK_AND_PUT)
  t:start()
  t:fill(100, 1, "main_deck", 10)
  t:put(1, 0, "lrig_center")
  t:put(1, 1, "lrig_center")
  t:fill(100, 0, "main_deck", 2)
  local top = {t:put(100, 0, "main_deck"), t:put(100, 0, "main_deck"), t:put(100, 0, "main_deck")}
  local arts = t:put(402, 0, "lrig_deck")
  return arts, top
end

case("look: 덱 위 3장을 보고 시그니 1장을 장에 내고, 나머지는 섞어서 덱 아래로", "WXDi-D01-011 (デッキの上から８枚見る…残りをシャッフルしてデッキの一番下)", function(t)
  local arts, top = look_setup(t)
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:global("SAW") == 3)
  t:expect(t:can_see(0, top[1]) and not t:can_see(1, top[1]), "본 사람만 안다")
  t:expect(t:answer(top[3]))
  t:expect(t:wait(HINT_ZONE))
  t:expect(#t:request().options == 3, "빈 시그니 존 3개")
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:global("PUT") == true and t:is_in(top[3], 0, "signi_left"))
  local deck = t:cards(0, "main_deck")
  t:expect(#deck == 4)
  local bottom = {deck[1], deck[2]}
  t:expect((bottom[1] == top[1] or bottom[1] == top[2]) and (bottom[2] == top[1] or bottom[2] == top[2]), "남은 2장은 맨 아래")
  t:expect(not t:can_see(0, top[1]), "섞어서 놓았으니 자리는 모른다")
end)

case("look: 리미트를 넘으면 장에 낼 수 없다", "용어집: リミット", function(t)
  local arts, top = look_setup(t, 1)
  t:put(100, 0, "signi_right")  -- 레벨 1, 리미트 1이 다 찼다
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:answer(top[3]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:global("PUT") == false and t:count(0, "main_deck") == 5, "못 낸 카드도 나머지와 함께 덱 아래")
end)

-- ── 키워드 ──

local function battle(t, keywords, opts)
  opts = opts or {}
  t:lrig(1, 3, 9, {"タマ"})
  t:signi(100, 1000)
  t:signi(110, 5000)
  t:start()
  t:fill(100, 0, "main_deck", 10)
  t:fill(100, 1, "main_deck", 10)
  t:put(1, 0, "lrig_center")
  t:put(1, 1, "lrig_center")
  t:fill(100, 1, "life_cloth", opts.life or 5)
  local a = t:put(110, 0, "signi_center")
  local d
  if not opts.no_front then d = t:put(100, 1, "signi_center") end
  for _, k in ipairs(keywords) do t:grant(a, k, 0, 0) end
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(a))
  return a, d
end

local function after_attack(t)
  return t:wait(HINT_ATTACK_LRIG)
end

case("keyword: 【ランサー】 배틀로 바니시하면 라이프 클로스 1장 크러시", "용어집: ランサー", function(t)
  local _, d = battle(t, {EFFECT_LANCER})
  t:expect(after_attack(t))
  t:expect(not t:is_in(d, 1, "signi_center"))
  t:expect(t:count(1, "life_cloth") == 4)
end)

case("keyword: 【ランサー】가 여럿이어도 1장", "용어집: ランサー", function(t)
  battle(t, {EFFECT_LANCER, EFFECT_LANCER})
  t:expect(after_attack(t))
  t:expect(t:count(1, "life_cloth") == 4)
end)

case("keyword: 【ランサー】+【ダブルクラッシュ】로 바니시해도 1장", "WXDi-D01-014 FAQ 2", function(t)
  battle(t, {EFFECT_LANCER, EFFECT_DOUBLE_CRUSH})
  t:expect(after_attack(t))
  t:expect(t:count(1, "life_cloth") == 4)
end)

case("keyword: 【ダブルクラッシュ】 데미지로 2장", "용어집: ダブルクラッシュ", function(t)
  battle(t, {EFFECT_DOUBLE_CRUSH}, {no_front = true})
  t:expect(after_attack(t))
  t:expect(t:count(1, "life_cloth") == 3)
end)

case("keyword: 【ダブルクラッシュ】 라이프 1장이면 1장만, 승리 아님", "용어집: ダブルクラッシュ", function(t)
  battle(t, {EFFECT_DOUBLE_CRUSH}, {no_front = true, life = 1})
  t:expect(after_attack(t))
  t:expect(t:count(1, "life_cloth") == 0 and not t:ended())
end)

case("keyword: 【アサシン】은 정면 시그니와 배틀하지 않고 데미지", "용어집: アサシン", function(t)
  local _, d = battle(t, {EFFECT_ASSASSIN})
  t:expect(after_attack(t))
  t:expect(t:is_in(d, 1, "signi_center") and t:count(1, "life_cloth") == 4)
end)

case("keyword: 라이프 0장에 【アサシン】 데미지면 승리", "용어집: アサシン", function(t)
  battle(t, {EFFECT_ASSASSIN}, {life = 0})
  t:expect(not after_attack(t))
  t:expect(t:ended() and t:winner() == 0)
end)

case("keyword: 【ランサー】+【アサシン】은 배틀이 없어 ランサー가 기능하지 않는다", "용어집: アサシン", function(t)
  local _, d = battle(t, {EFFECT_LANCER, EFFECT_ASSASSIN})
  t:expect(after_attack(t))
  t:expect(t:is_in(d, 1, "signi_center") and t:count(1, "life_cloth") == 4, "데미지 1장만")
end)
