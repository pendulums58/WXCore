-- 테스트 모드: 확정 후 되돌리기(기록 재실행)

-- 상대 시그니 1체를 대상으로 바니시하는 스펠
local BANISH_SPELL = [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingTarget(Card.IsSigni,tp,0,LOCATION_SZONE,1,nil) end
  Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
end
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
end
]]

local function setup(t)
  t:lrig(1, 3, 9, {"タマ"})
  t:signi(100, 5000)
  t:card{cid = 400, type = TYPE_SPELL, cost = "{W}"}
  t:script(400, BANISH_SPELL)
  t:start()
  t:fill(100, 0, "main_deck", 10)
  t:fill(100, 1, "main_deck", 10)
  t:put(1, 0, "lrig_center")
end

local function deck40(first, n)
  local d = {}
  for i = 0, 39 do d[#d + 1] = first + i % (n or 1) end
  return d
end

case("undo: 확정한 뒤에도 마지막 응답을 되돌린다", "설계: 테스트 모드 「確定後にも戻す」", function(t)
  setup(t)
  local spell = t:put(400, 0, "hand")
  local white = t:put(100, 0, "ena")
  local a = t:put(100, 1, "signi_left")
  local b = t:put(100, 1, "signi_right")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_USE, spell)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(white))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(a))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 1, "ena") and t:is_in(spell, 0, "trash"))

  -- 마지막 응답 = 메인으로 돌아오는 사이의 기본 응답(컷인 창 등). 대상 요청까지 하나씩 되돌린다
  local steps = 0
  repeat
    t:expect(t:undo())
    steps = steps + 1
  until t:request().hint == HINT_TARGET or steps > 10
  t:expect(t:request().hint == HINT_TARGET, "대상 요청으로 돌아왔다")
  t:expect(t:is_in(a, 1, "signi_left"), "바니시 전으로")
  t:expect(t:is_in(spell, 0, "hand") and t:is_in(white, 0, "ena"), "확정 전 상태")

  t:expect(t:answer(b), "다른 대상을 고를 수 있다")
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(b, 1, "ena") and t:is_in(a, 1, "signi_left"))
end)

case("undo: Lua 선택 요청 도중에도 되돌린다", "설계: 테스트 모드 (랜덤 대전 seed 4에서 찾은 크래시)", function(t)
  setup(t)
  local spell = t:put(400, 0, "hand")
  local white = t:put(100, 0, "ena")
  t:put(100, 1, "signi_left")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_USE, spell)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(white))
  t:expect(t:wait(HINT_TARGET), "스크립트의 SelectTarget에서 멈춤")
  t:expect(t:undo())
  t:expect(t:request().hint == HINT_PAY_ENA)
  t:expect(t:answer(white))
  t:expect(t:wait(HINT_TARGET))
end)

case("undo: 응답이 없으면 되돌릴 수 없다", "설계: 테스트 모드", function(t)
  setup(t)
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:undo())
  t:expect(t:request().hint == HINT_MAIN, "상태는 그대로")
end)

case("undo: 테스트 모드가 아니면 거부", "AGENTS.md: 코어 규칙", function(t)
  t:lrig(2, 0, 0, {"タマ"})
  t:signi(100, 1000)
  t:start{test_mode = false, first = 0}
  t:deck(0, deck40(100), {2})
  t:deck(1, deck40(100), {2})
  t:start_game()
  t:expect(t:wait(HINT_MULLIGAN))
  t:expect(t:answer())
  t:expect(not t:undo())
end)

case("undo: 셔플·난수가 있어도 같은 상태로 돌아온다", "설계: 결정론(리플레이 = 덱 + 시드 + 응답)", function(t)
  t:lrig(2, 0, 0, {"タマ"})
  for c = 100, 109 do t:signi(c, 1000) end
  t:start{seed = 5, first = 0}
  t:deck(0, deck40(100, 10), {2})
  t:deck(1, deck40(100, 10), {2})
  t:start_game()
  t:expect(t:wait(HINT_MULLIGAN))
  local hand = table.concat(t:cards(0, "hand"), ",")
  local r = t:request()
  t:expect(t:answer(r.options[1], r.options[2], r.options[3]))
  t:expect(t:wait(HINT_MULLIGAN))
  t:expect(t:request().player == 1)
  t:expect(t:undo())
  t:expect(t:request().player == 0, "선공의 引き直し 선언으로")
  t:expect(table.concat(t:cards(0, "hand"), ",") == hand, "같은 패")
  t:expect(t:answer())
  t:expect(t:wait(HINT_MULLIGAN))
  t:expect(table.concat(t:cards(0, "hand"), ",") == hand, "이번엔 안 바꿨다")
end)

case("undo: 되돌린 응답 뒤의 테스트 명령도 없어진다", "설계: 테스트 모드", function(t)
  setup(t)
  local mine = t:put(100, 0, "signi_center")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:single(mine, EFFECT_UPDATE_POWER, 1000, 0)  -- [まで] 응답 전 명령: 남는다
  t:expect(t:answer(t:action(ACT_END)))
  t:single(mine, EFFECT_UPDATE_POWER, 2000, 0)  -- [まで] 응답 뒤 명령: 없어진다
  t:expect(t:power(mine) == 8000)
  t:expect(t:undo())
  t:expect(t:request().hint == HINT_MAIN)
  t:expect(t:power(mine) == 6000)
end)

case("undo: 다시 실행할 때 로그를 또 내지 않는다", "설계: 테스트 모드", function(t)
  t:allow_logs()
  setup(t)
  t:put(999, 0, "hand")  -- 카드 데이터 없음 → 로그 1건
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  local n = t:logs()
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:undo())
  t:expect(t:logs() == n)
end)
