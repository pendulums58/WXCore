-- 번외(PR) 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local WS, OPP, MID, BIG, LV4, LV0 = 200000, 101000, 101500, 102000, 300100, 300101

local function base(t, opts)
  opts = opts or {}
  t:start{db = true, seed = 1}
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(OPP, 3000, COLOR_RED, 1)
  t:signi(MID, 9000, COLOR_RED, 3)
  t:signi(BIG, 15000, COLOR_RED, 4)
  t:lrig(LV4, 4, 11, {"タマ"}, COLOR_WHITE)
  t:lrig(LV0, 0, 0, {"タマ"}, COLOR_WHITE)
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(opts.opp or LV4, 1, "lrig_center")
  return t:put(opts.center or LV4, 0, "lrig_center")
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

local function pay(t, n)
  t:expect(t:wait(HINT_PAY_ENA), "에나 " .. n)
  t:expect(t:answer(table.unpack(t:cards(0, "ena"), 1, n)))
end

local function use(t, c) t:expect(t:answer(t:action(ACT_USE, c))) end

case("ゲームに敗北する: 파워 0 이하로 룰 처리 바니시되면 진다", "PR-422 FAQ 1", function(t)
  base(t)
  local s = t:put(t:no("PR-422"), 0, "signi_left")
  t:single(s, EFFECT_UPDATE_POWER, -8000, 0)
  main(t)
  t:answer(t:action(ACT_END))  -- 다음 룰 처리에서 바니시되고 진다
  t:step()
  t:expect(t:ended() and t:winner() == 1, "패배")
end)

case("デッキがシャッフルされたとき: 리프레시·효과 셔플마다 트리거", "PR-470A FAQ 1", function(t)
  base(t)
  local s = t:put(t:no("PR-470A"), 0, "signi_left")
  local sp = t:put(t:no("PR-318"), 0, "hand")  -- 덱에서 찾고 셔플
  ena(t, 1)
  main(t)
  use(t, sp)
  pay(t, 1)
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:answer())
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(s) == 10000, "5000 + 5000")
end)

case("ストール・ストーリー: 상대 루리그 트래시의 아츠를 색을 무시하고 쓴다", "PR-433 FAQ 4", function(t)
  base(t)
  local arts = t:put(t:no("PR-433"), 0, "lrig_deck")
  local other = t:put(t:no("PR-474"), 1, "lrig_trash")  -- 《白》×0 아츠
  local x = t:put(BIG, 1, "signi_left")
  t:put(t:no("PR-467"), 0, "ena")  -- 녹색 카드로
  main(t)
  use(t, arts)
  pick(t, HINT_TARGET, other)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:action(ACT_USE, other) ~= nil, "이 턴 동안 내 루리그 덱에 있는 것처럼")
end)

case("カウンター・ヴァンプ: 이 턴에 상대 효과로 떠난 시그니가 없으면 ①은 아무 일도 없다", "PR-463 FAQ 1", function(t)
  base(t)
  local arts = t:put(t:no("PR-463"), 0, "lrig_deck")
  local x = t:put(BIG, 1, "signi_left")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DEFENSE))
  use(t, arts)
  pick(t, HINT_MODE, 0)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_DEFENSE) or t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:is_in(x, 1, "signi_left"))
end)

case("星占の巫女　リメンバ・ナイト: 상대 루리그의 【起】 코스트가 《無》 하나 늘어난다", "PR-046 FAQ 2", function(t)
  base(t, {opp = t:no("PR-046")})
  local lc = t:cards(0, "lrig_center")[1]
  t:script(LV4, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_LRIG)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end]])
  main(t)
  t:expect(t:action(ACT_ABILITY, lc) == nil, "엔이 없으면 쓸 수 없다")
end)

case("五体合体　グレートタマヨリオー: 레벨 0에서 ＜タマ＞ 5장을 제외하고 그로우", "PR-469", function(t)
  base(t, {center = LV0})
  local g = t:put(t:no("PR-469"), 0, "lrig_deck")
  local ls = {}
  for i = 1, 5 do ls[i] = t:put(LV4, 0, "lrig_deck") end
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:answer(table.unpack(ls)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(g, 0, "lrig_center") and t:is_in(ls[1], 0, "exclude"), tostring(t:is_in(g, 0, "lrig_center")) .. " " .. tostring(t:is_in(ls[1], 0, "exclude")) .. " ex " .. t:count(0, "exclude") .. " ld " .. t:count(0, "lrig_deck") .. " lt " .. t:count(0, "lrig_trash"))
end)

