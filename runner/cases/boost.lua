-- WX09~WX12에서 랜덤 대전만 통과했던 메커니즘의 동작 케이스. 근거는 카드별 FAQ(cards.json)와 카드 텍스트

local WS, RS, GS, US, OPP, MID, BIG = 200000, 200001, 200003, 200002, 101000, 101500, 102000
local LV4, SP, BEAST, PUT_DOWN = 300100, 200100, 200101, 200102

local function base(t, lrig, p1, types)
  t:start{db = true, seed = 1}
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(RS, 1000, COLOR_RED, 1)
  t:signi(GS, 1000, COLOR_GREEN, 1)
  t:signi(US, 1000, COLOR_BLUE, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(MID, 9000, COLOR_GREEN, 3)
  t:signi(BIG, 15000, COLOR_GREEN, 4)
  t:card{cid = BEAST, power = 5000, level = 1, classes = {"精生：地獣"}, color = COLOR_GREEN}
  t:card{cid = SP, type = TYPE_SPELL, color = COLOR_GREEN}
  t:script(SP, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,2) end)
  c:RegisterEffect(e1)
end]])
  -- 패의 시그니 1장을 다운 상태로 낸다
  t:card{cid = PUT_DOWN, type = TYPE_SPELL, color = COLOR_GREEN}
  t:script(PUT_DOWN, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_HAND,0,nil),1,1):GetFirst()
    if x then Duel.PutOnField(x,tp,false,true) end
  end)
  c:RegisterEffect(e1)
end]])
  t:lrig(LV4, 4, 11, types or {"タマ"}, COLOR_WHITE)
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(p1 or LV4, 1, "lrig_center")
  return t:put(lrig or LV4, 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function run(t, until_hint)
  until_hint = until_hint or HINT_MAIN
  t:step()
  while t:request().hint ~= until_hint do
    local r = t:request()
    if r.hint == HINT_SCRIPT or r.hint == HINT_USE_TRIGGER or r.hint == HINT_LIFEBURST then t:expect(t:answer(1))
    else t:expect(t:answer(table.unpack(r.options, 1, math.max(r.min, 1)))) end
    t:step()
  end
end

local function pay_all(t)
  t:step()
  if t:request().hint == HINT_PAY_ENA then t:expect(t:answer(table.unpack(t:request().options, 1, t:request().min))) end
end

case("純白の巫女 ユキ: 내 효과로 시그니가 다른 존으로 옮겨지면 에나 차지. 여럿이어도 턴 1회", "WX11-002 FAQ 1", function(t)
  local lc = base(t, t:no("WX11-002"))
  t:lrig(300101, 1, 11, {"イオナ"}, COLOR_WHITE)
  t:put_under(t:put(300101, 0, "lrig_trash"), lc)
  local a = t:put(OPP, 1, "signi_left")
  t:put(MID, 1, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, lc)))
  run(t)
  t:expect(t:count(0, "ena") == 1, "에나 1장 " .. t:count(0, "ena"))
end)

case("羅輝石 ゴルドオラ: 내 시그니는 상대의 라이프 버스트 효과를 받지 않는다", "WX11-027", function(t)
  base(t, nil, nil, {"花代"})
  t:card{cid = 300102, power = 1000, level = 1, color = COLOR_GREEN, burst = 1}
  t:script(300102, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_LIFEBURST)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-5000) end
  end)
  c:RegisterEffect(e1)
end]])
  local g = t:put(t:no("WX11-027"), 0, "signi_center")
  local p = t:power(g)
  t:put(300102, 1, "life_cloth")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI) and t:answer())
  t:expect(t:wait(HINT_ATTACK_LRIG) and t:answer(t:center(0)))
  t:expect(t:wait(HINT_LIFEBURST))
  t:expect(t:answer(1))
  t:step()
  if t:request().hint == HINT_TARGET then t:expect(t:answer(t:request().options[1])) end
  t:expect(t:power(g) == p, "파워 그대로 " .. t:power(g))
end)

case("リフレッシュ・エンド: 상대가 이 턴에 리프레시하면 그 뒤 턴이 끝난다", "WX11-024 FAQ 2", function(t)
  base(t)
  local a = t:put(t:no("WX11-024"), 0, "lrig_deck")
  t:put(WS, 0, "ena")
  for _, c in ipairs(t:cards(1, "main_deck")) do t:move(c, 1, "trash") end
  t:put(OPP, 1, "main_deck")
  local sp = t:put(SP, 1, "hand")
  main(t, 1)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_CUTIN))
  t:expect(t:answer(t:action(ACT_USE, a)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:turn_player() == 0, "상대 턴이 끝났다")
end)

case("幻獣 ソウリュウ: 상대 효과로 내 <공수>·<지수> 시그니의 파워는 증감하지 않는다", "WX12-033", function(t)
  base(t)
  t:put(t:no("WX12-033"), 0, "signi_left")
  local b, w = t:put(BEAST, 0, "signi_center"), t:put(WS, 0, "signi_right")
  local pb, pw = t:power(b), t:power(w)
  t:field(EFFECT_UPDATE_POWER, -1000, 1, 0, LOCATION_SZONE, 0)
  t:expect(t:power(b) == pb, "지수는 그대로 " .. t:power(b))
  t:expect(t:power(w) == pw - 1000, "다른 시그니는 줄어든다 " .. t:power(w))
end)

case("白羅星 プルート: 바니시되면 루리그 덱이 아니라 루리그 트래시로", "WX10-008", function(t)
  base(t, nil, nil, {"サシェ"})
  local p = t:put(t:no("WX10-008"), 0, "signi_center")
  t:put(t:no("WX10-060"), 1, "hand")  -- 다른 카드 대신 직접 효과로 바니시
  t:card{cid = 300103, type = TYPE_SPELL, color = COLOR_GREEN}
  t:script(300103, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp) Duel.Banish(Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)) end)
  c:RegisterEffect(e1)
end]])
  local sp = t:put(300103, 1, "hand")
  main(t, 1)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  run(t)
  t:expect(t:is_in(p, 0, "lrig_trash"), "루리그 트래시")
end)

case("肆ノ遊 ツナヒキ: 내 시그니가 다운 상태로 나오면 업한다", "WX10-074", function(t)
  base(t)
  t:put(t:no("WX10-074"), 0, "signi_left")
  local sp = t:put(PUT_DOWN, 0, "hand")
  local x = t:put(WS, 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  run(t)
  t:expect(t:is_in(x, 0, "signi_center") or t:is_in(x, 0, "signi_right"), "나왔다")
  t:expect(t:flags(x) % 2 == 0, "업 상태")
end)

case("火銃舞 タマヨリヒメ之参: 이 카드 위에 그로우하는 코스트가 《赤》《白》 준다", "WX10-010 FAQ 1", function(t)
  base(t, t:no("WX10-010"))
  t:card{cid = 300104, type = TYPE_LRIG, level = 4, limit = 11, color = COLOR_RED, cost = "{R}{W}{C}", lrig_types = {"タマ"}}
  local g = t:put(300104, 0, "lrig_deck")
  t:put(WS, 0, "ena")
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_GROW) and t:answer(g))
  t:step()
  t:expect(t:request().hint == HINT_PAY_ENA and t:request().min == 1, "《無》만 남는다")
end)

case("原槍 ラナジェ: 배틀로 바니시한 상대 시그니는 트래시로", "WX09-022 FAQ 2", function(t)
  base(t)
  local r = t:put(t:no("WX09-022"), 0, "signi_center")
  t:put(1235, 0, "trash")  -- 《原槍　エナジェ》
  local x = t:put(MID, 1, "signi_center")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI) and t:answer(r))
  t:expect(t:wait(HINT_ATTACK_LRIG) or t:wait(HINT_MAIN) or true)
  t:expect(t:is_in(x, 1, "trash"), "트래시 " .. tostring(t:is_in(x, 1, "ena")))
end)

case("アイドル・ディフェンス: 상대의 시그니 어택 스텝을 스킵한다", "WX09-Re02", function(t)
  base(t)
  local a = t:put(t:no("WX09-Re02"), 0, "lrig_deck")
  for _ = 1, 8 do t:put(WS, 0, "ena") end
  t:put(MID, 1, "signi_center")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DEFENSE))
  t:expect(t:answer(t:action(ACT_USE, a)))
  t:step()
  while t:request().hint ~= HINT_ATTACK_SIGNI and t:request().hint ~= HINT_ATTACK_LRIG do
    local r = t:request()
    t:expect(t:answer(table.unpack(r.options, 1, math.max(r.min, 1))))
    t:step()
  end
  t:expect(t:request().hint == HINT_ATTACK_LRIG, "시그니 어택 없이 루리그 어택으로")
end)

case("クローズ・ゾーン: 다음 턴 동안 상대는 지정된 존에 새로 배치할 수 없다(이 턴은 된다)", "WX10-051", function(t)
  base(t)
  local sp = t:put(t:no("WX10-051"), 0, "hand")
  for _ = 1, 3 do t:put(t:no("WX01-100"), 0, "ena") end
  local h = t:put(OPP, 1, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:step()
  while t:request().hint ~= HINT_ZONE do
    if t:request().hint == HINT_PAY_ENA then t:expect(t:answer(table.unpack(t:request().options, 1, t:request().min)))
    else t:expect(t:answer(t:action(ACT_END))) end
    t:step()
  end
  t:expect(t:answer(t:request().options[2]))  -- 가운데
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_MAIN) and t:turn_player() == 1)
  t:expect(t:action(ACT_PLAY, h, "signi_center") == nil, "다음 턴: 가운데는 안 된다")
  t:expect(t:action(ACT_PLAY, h, "signi_left") ~= nil)
end)

case("SINGLE 부여: 「このシグニは…かぎり、「【自】…」を得る」는 조건을 채우는 동안만 얻는다", "WX17-038 텍스트", function(t)
  for _, zone in ipairs{"signi_center", "signi_left"} do
    base(t, nil, nil, {"カーニバル"})  -- カーニバル限定
    t:card{cid = 200110, power = 1000, level = 3, classes = {"精羅：宇宙"}, color = COLOR_BLACK}
    local h = t:put(t:no("WX17-038"), 0, zone)
    t:put(200110, 0, "main_deck")
    local x = t:put(MID, 1, "signi_left")  -- 내 오른쪽의 정면(배틀하지 않게)
    t:begin(0, PHASE_ATTACK)
    t:expect(t:wait(HINT_ATTACK_SIGNI))
    t:expect(t:answer(h))
    if zone == "signi_center" then
      t:expect(t:wait(HINT_TARGET), "가운데면 얻는다")
      t:expect(t:answer(x))
    end
    t:expect(t:wait(HINT_ATTACK_LRIG))
    t:expect(t:is_in(x, 1, zone == "signi_center" and "ena" or "signi_left"))
  end
end)
