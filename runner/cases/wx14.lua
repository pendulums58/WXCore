-- WX14 부스터 카드 스크립트 케이스(상대 루리그 대미지 막기, 【出】 봉쇄, 무색 금지, 빈 존으로 옮기기 등). 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, OPP, MID, GS = 200000, 101000, 101500, 200003
local LV4, NOVA5, PLANT = 300120, 300121, 200120

local function wd(t, lrig, p1)
  t:start{db = true, seed = 1}
  local function pick_card(x) return type(x) == "string" and t:no(x) or N[x] or x end
  for i = 1, 79 do N[i] = t:no(("WX14-%03d"):format(i)) end
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(GS, 1000, COLOR_GREEN, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(MID, 9000, COLOR_GREEN, 3)
  t:card{cid = PLANT, power = 2000, level = 1, classes = {"精羅：植物"}, color = COLOR_GREEN}
  t:lrig(LV4, 4, 11, {"緑子"}, COLOR_GREEN)
  t:lrig(NOVA5, 5, 11, {"イオナ"}, COLOR_WHITE)
  lrig, p1 = pick_card(lrig or LV4), pick_card(p1 or LV4)
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(p1, 1, "lrig_center")
  return t:put(lrig, 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

case("紡ぐ者: 다음 턴 동안 상대 루리그는 나에게 대미지를 주지 않는다", "WX14-003", function(t)
  local lc = wd(t, 3)
  t:put(WS, 0, "ena")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, lc)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_END)))
  t:step()
  while not (t:request().hint == HINT_ATTACK_LRIG and t:request().player == 1) do
    local r = t:request()
    t:expect(t:answer(table.unpack(r.options, 1, r.min)) or t:answer(t:action(ACT_END)))
    t:step()
  end
  t:expect(t:answer(t:center(1)))
  t:step()
  if t:request().hint == HINT_GUARD then t:expect(t:answer()) end
  t:expect(t:count(0, "life_cloth") == 5, "대미지 없음 " .. t:count(0, "life_cloth"))
end)

case("コードキャッスル ヴェルサ: 상대 시그니의 【出】은 발동하지 않는다", "WX14-023", function(t)
  for _, versa in ipairs{true, false} do
    wd(t, NOVA5)
    if versa then t:put(N[23], 0, "signi_center") end
    t:card{cid = 200121, power = 1000, level = 1, color = COLOR_GREEN}
    t:script(200121, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end]])
    local y = t:put(200121, 1, "hand")
    main(t, 1)
    local h = t:count(1, "hand")
    t:expect(t:answer(t:action(ACT_PLAY, y, "signi_left")))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(1, "hand") == (versa and h - 1 or h), versa and "뽑지 않았다" or "뽑았다")
  end
end)

case("緑羅植 ユグドラ: 무색 시그니는 낼 수 없고, 무색이 아닌 에나는 모든 색", "WX14-017", function(t)
  wd(t, LV4)
  t:put(N[17], 0, "signi_center")
  local s = t:put(t:no("WX01-100"), 0, "hand")  -- サーバント 무색
  t:put(WS, 0, "ena")
  local sp = t:put(t:no("WX01-063"), 0, "hand")  -- 《白》 스펠은 원래 낼 수 있다
  t:put(GS, 0, "ena")
  t:move(t:cards(0, "ena")[1], 0, "exclude")
  main(t)
  t:expect(t:action(ACT_PLAY, s, "signi_left") == nil, "무색은 못 낸다")
  t:expect(t:action(ACT_USE, sp) ~= nil, "녹색 에나로 《白》")
end)

case("コードメイズ レイハイ: 상대가 어택하면 빈 존으로 옮기고 ＋3000", "WX14-050", function(t)
  wd(t, NOVA5)
  local r = t:put(N[50], 0, "signi_left")
  local p = t:power(r)
  local x = t:put(MID, 1, "signi_center")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI) and t:answer(x))
  t:expect(t:wait(HINT_SCRIPT) and t:answer(1))
  t:expect(t:wait(HINT_ZONE) and t:answer(t:request().options[1]))
  t:step()
  t:expect(not t:is_in(r, 0, "signi_left") and t:power(r) == p + 3000, "옮겨졌고 ＋3000 " .. t:power(r))
end)

case("コードキャッスル ヴェルサ: 양쪽에 여러 장 있어도 봉쇄 판정이 끝난다", "WX14-023 / 버그: 영역 밖 봉쇄 재귀", function(t)
  wd(t, NOVA5, NOVA5)
  t:put(N[23], 0, "signi_center")
  t:put(N[23], 1, "signi_center")
  for p = 0, 1 do for _ = 1, 4 do t:put(N[23], p, "hand") end for _ = 1, 4 do t:put(N[23], p, "main_deck") end end
  main(t)
  t:expect(t:action(ACT_END) ~= nil, "메인 페이즈에 도달")
end)
