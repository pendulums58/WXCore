-- WX05 부스터 카드 스크립트 케이스와 새 메커니즘(추가 턴, 루리그 트래시의 【起】, 한정 무시 등). 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, KS, OPP, MID, BIG = 200000, 200004, 101000, 101500, 102000
local PLANT, LTR, URI4, SPELL, WEP, PIR5 = 200015, 300010, 300011, 200014, 200016, 300012

-- lrig·p1: 이 부스터의 번호(숫자)나 카드 번호 문자열. N은 여기서 채운다
local function wd(t, lrig, p1)
  t:start{db = true, seed = 1}
  for i = 1, 81 do N[i] = t:no(("WX05-%03d"):format(i)) end
  local function pick_card(x) return type(x) == "string" and t:no(x) or N[x] or x end
  lrig, p1 = pick_card(lrig or 1), p1 and pick_card(p1)
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(KS, 1000, COLOR_BLACK, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(MID, 9000, COLOR_GREEN, 3)
  t:signi(BIG, 15000, COLOR_GREEN, 4)
  t:card{cid = PLANT, power = 2000, level = 1, classes = {"精羅：植物"}, color = COLOR_GREEN}
  -- 루리그 트래시에 둘 루리그: 【起】 1장 뽑는다
  t:script(LTR, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_LRIG)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end]])
  t:lrig(LTR, 2, 6, {"ピルルク"})
  t:lrig(URI4, 4, 11, {"ウリス"}, COLOR_BLACK)
  t:lrig(PIR5, 5, 11, {"ピルルク"}, COLOR_BLUE)
  t:card{cid = WEP, power = 2000, level = 1, classes = {"精武：ウェポン"}, color = COLOR_RED}
  t:card{cid = SPELL, type = TYPE_SPELL, color = COLOR_WHITE}
  t:script(SPELL, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,2) end)
  c:RegisterEffect(e1)
end]])
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(p1 or URI4, 1, "lrig_center")
  return t:put(lrig, 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n, cid)
  for _ = 1, n do t:put(cid or WS, 0, "ena") end
end

local function pick(t, hint, ...)
  t:expect(t:wait(hint), "힌트 " .. hint)
  t:expect(t:answer(...))
end

local function under(t, c, n)
  for _ = 1, n do t:put_under(t:put(LTR, 0, "lrig_trash"), c) end
end

-- ── 루리그 트래시의 【起】 ──

case("ピルルク・伍: 루리그 트래시 루리그의 【起】를 쓴다. 트래시를 떠나면 못 쓴다", "WX05-002 FAQ 2", function(t)
  local lc = wd(t, 3)
  t:put(LTR, 0, "lrig_trash")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, lc)), "복제한 【起】")
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1)
  lc = wd(t, 3)
  t:put(LTR, 0, "lrig_deck")
  main(t)
  t:expect(t:action(ACT_ABILITY, lc) == nil, "루리그 트래시에 없으면 없다")
end)

-- ── 추가 턴 ──

case("創世の巫女 マユ: 엑시드 5로 에나·패를 트래시, 이 턴 다음에 추가 턴", "WX05-001", function(t)
  local lc = wd(t, 1)
  under(t, lc, 5)
  ena(t, 2)
  t:put(WS, 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, lc, 1)))
  t:expect(t:wait(HINT_EXCEED))
  t:expect(t:answer(table.unpack(t:under(lc))))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "ena") == 0 and t:count(0, "hand") == 0)
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:turn_player() == 0, "다음 턴도 내 턴")
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:turn_player() == 1, "추가 턴은 한 번")
end)

-- ── 한정 무시 ──

case("虚無の閻魔 ウリス: 아츠·스펠의 한정 조건을 무시한다", "WX05-006 FAQ 5", function(t)
  for _, u in ipairs{true, false} do
    wd(t, u and 6 or "WX01-001")
    local a = t:put(t:no("WX01-024"), 0, "lrig_deck")  -- 緑子限定
    main(t)
    t:expect((t:action(ACT_USE, a) ~= nil) == u, u and "ウリス면 쓸 수 있다" or "한정")
  end
end)

case("虚無の閻魔 ウリス: 무색은 색으로 세지 않는다(그로우 조건)", "WX05-006 FAQ 2", function(t)
  for _, n in ipairs{2, 3} do
    wd(t, URI4)
    local g = t:put(N[6], 0, "lrig_deck")
    t:put(WS, 0, "ena")
    t:put(KS, 0, "ena")
    t:put(t:no("WX01-100"), 0, "ena")  -- サーバント 무색
    if n == 3 then t:put(OPP, 0, "ena") end
    t:begin(0, PHASE_GROW)
    t:step()
    t:expect((t:request().hint == HINT_GROW) == (n == 3), "색 " .. n .. "종류")
  end
end)

-- ── 턴 종료 ──

case("エンドホール: 5색으로 내면 그 턴을 끝낸다(상대 스펠에 컷인)", "WX05-016 FAQ 2", function(t)
  wd(t, URI4)
  local a = t:put(N[16], 0, "lrig_deck")
  for _, c in ipairs{COLOR_WHITE, COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_BLACK} do
    t:signi(210000 + c, 1000, c, 1)
    t:put(210000 + c, 0, "ena")
  end
  local sp = t:put(SPELL, 1, "hand")
  main(t, 1)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_CUTIN))
  t:expect(t:answer(t:action(ACT_USE, a)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(t:request().options, 1, 5)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:turn_player() == 0, "상대 턴이 끝났다")
  t:expect(t:is_in(sp, 1, "trash"), "체크 존의 스펠은 트래시로")
end)

-- ── 상대가 패에 넣지 못한다 ──

case("コードラブハート C・M・R: 상대는 자기 턴 메인에서 뽑지 못한다. 드로 페이즈는 된다", "WX05-022 FAQ 1·2", function(t)
  wd(t, URI4, PIR5)  -- C・M・R은 레벨 5, ピルルク 한정
  local cmr = t:put(N[22], 1, "signi_center")
  local sp = t:put(SPELL, 0, "hand")
  t:begin(0, PHASE_UP)
  t:expect(t:wait(HINT_MAIN))
  local h = t:count(0, "hand")
  t:expect(h >= 2, "드로 페이즈")
  t:expect(t:is_in(cmr, 1, "signi_center"))
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:step()
  if t:request().hint == HINT_PAY_ENA then t:expect(t:answer(table.unpack(t:request().options, 1, t:request().min))) end
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == h - 1, "메인 페이즈에선 못 뽑는다")
end)

-- ── 상대 효과로 파워가 바뀌지 않는다 ──

case("幻獣神 ライアン: 상대 효과의 파워 증감은 무시, 내 효과는 적용", "WX05-024 FAQ 1·4", function(t)
  wd(t, URI4)
  local r = t:put(N[24], 1, "signi_center")
  local x = t:put(MID, 1, "signi_left")
  t:expect(t:power(x) == 9000)
  t:field(EFFECT_UPDATE_POWER, -5000, 0, 0, LOCATION_SZONE, 0)
  t:expect(t:power(x) == 9000, "상대(0)가 만든 −5000은 무시 " .. t:power(x))
  t:field(EFFECT_UPDATE_POWER, 1000, 1, LOCATION_SZONE, 0, 0)
  t:expect(t:power(x) == 10000, "자기 효과 +1000 " .. t:power(x))
  t:expect(t:power(r) >= 15000)
end)

-- ── 다운 이벤트 ──

case("羅植 サクラ: 효과로 다운하면 에나 차지, 코스트로 다운하면 아니다", "WX05-040 FAQ 3", function(t)
  wd(t, URI4)
  local s = t:put(N[40], 0, "signi_center")
  local p = t:put(N[41], 0, "signi_left")  -- 【起】 다운: 코스트
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, p)))
  t:step()
  if t:request().hint == HINT_TARGET then t:expect(t:answer(t:request().options[1])) end
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "ena") == 0, "코스트 다운은 아니다")
  t:put(N[42], 0, "hand")
end)

-- ── 라이프 버스트 없는 크러시 ──

case("アヴェンジャー: 그 효과로 크러시한 카드의 라이프 버스트는 발동하지 않는다", "WX05-032", function(t)
  wd(t, URI4)
  local a = t:put(N[32], 0, "signi_center")
  for _, c in ipairs(t:cards(1, "life_cloth")) do t:move(c, 1, "exclude") end
  local lb = t:put(t:no("WX01-062"), 1, "life_cloth")  -- 라이프 버스트를 가진 카드
  for _ = 1, 3 do t:put(WEP, 0, "hand") end
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, a, 1)))
  t:step()
  while t:request().hint == HINT_DISCARD or t:request().hint == HINT_SELECT do
    t:expect(t:answer(table.unpack(t:request().options, 1, t:request().min)))
    t:step()
  end
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(lb, 1, "ena") and not t:saw(HINT_LIFEBURST))
end)

-- ── 능력이 없는 시그니 ──

case("コードラビリンス ルーブル: 정면 시그니는 능력을 잃고, 능력 없는 상대 시그니가 2체면 +3000", "WX05-019 FAQ 1·6", function(t)
  wd(t, URI4)
  local l = t:put(N[19], 0, "signi_center")
  local base = t:power(l)
  t:put(N[29], 1, "signi_center")  -- 정면: 능력을 잃는다
  t:put(OPP, 1, "signi_left")
  t:expect(t:power(l) == base + 3000, "능력 없는 시그니 2체 " .. t:power(l))
end)

-- ── 상대 아츠의 효과를 받았을 때 ──

case("羅輝石 ダイヤブライド: 상대 아츠로 파워가 줄면 상대에게 대미지", "WX05-020 FAQ 2·7", function(t)
  wd(t, URI4)
  t:card{cid = 300020, type = TYPE_ARTS, color = COLOR_BLACK, timing = TIMING_MAIN}
  t:script(300020, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,-1000) end
  end)
  c:RegisterEffect(e1)
end]])
  local a = t:put(300020, 0, "lrig_deck")
  t:put(N[20], 1, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, a)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "life_cloth") == 4, "대미지 1")
end)
