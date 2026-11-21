-- WXDi-D01 ANCIENT SURPRISE 카드 스크립트(expansions/official/script) 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}  -- 카드 번호 → cid (t:no)

-- 실제 DB 대전. 루리그: center, assists. 덱은 채움용 시그니 100
local function d01(t, lrigs, opts)
  opts = opts or {}
  t:start{db = true, seed = opts.seed or 1}
  for no in ("001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 018 019 020 021"):gmatch("%d+") do
    N[no] = t:no("WXDi-D01-" .. no)
  end
  t:card{cid = 100, power = 1000, level = 1, classes = {"精械：迷宮"}}
  if not opts.no_deck then t:fill(100, 0, "main_deck", 10) end
  t:fill(100, 1, "main_deck", 10)
  t:fill(100, 1, "life_cloth", 5)
  t:put(N["004"], 1, "lrig_center")  -- 상대 센터 Lv3: 상대 시그니가 룰 처리로 사라지지 않게
  local zones = {"lrig_center", "lrig_assist_left", "lrig_assist_right"}
  local out = {}
  for i, no in ipairs(lrigs) do out[i] = t:put(N[no], 0, zones[i]) end
  return table.unpack(out)
end

-- 클래스만 다른 채움 시그니
local function signi(t, cid, classes, opts)
  opts = opts or {}
  t:card{cid = cid, power = opts.power or 1000, level = opts.level or 1, color = opts.color or COLOR_WHITE,
         classes = classes}
end

local function main(t)
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

-- ── 004 アト＝トレ ──

case("D01-004: 【チーム起】 서로 다른 클래스 3체 +3000, 《ターン1回》", "WXDi-D01-004 FAQ 1", function(t)
  local center = d01(t, {"004", "005", "008"})
  signi(t, 101, {"奏羅：宇宙"})
  signi(t, 102, {"奏像：武勇"})
  signi(t, 103, {"奏武：毒牙"})
  local a, b, c = t:put(101, 0, "signi_left"), t:put(102, 0, "signi_center"), t:put(103, 0, "signi_right")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, center)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:request().min == 3 and t:request().max == 3)
  t:expect(t:answer(a, b, c))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(a) == 4000 and t:power(b) == 4000 and t:power(c) == 4000)
  t:expect(t:action(ACT_ABILITY, center) == nil, "《ターン1回》")
end)

case("D01-004: 「３体」이라 2체로는 쓸 수 없다", "WXDi-D01-004 FAQ 2", function(t)
  local center = d01(t, {"004", "005", "008"})
  signi(t, 101, {"奏羅：宇宙"})
  signi(t, 102, {"奏像：武勇"})
  t:put(101, 0, "signi_left")
  t:put(102, 0, "signi_center")
  main(t)
  t:expect(t:action(ACT_ABILITY, center) == nil)
end)

case("D01-004: 겹치는 클래스가 있어도 하나씩 다르게 맞출 수 있으면 된다", "WXDi-D01-004 FAQ 4·5", function(t)
  local center = d01(t, {"004", "005", "008"})
  signi(t, 101, {"英知", "遊具"})
  signi(t, 102, {"宇宙", "遊具"})
  signi(t, 103, {"英知", "トリック"})
  t:put(101, 0, "signi_left")
  t:put(102, 0, "signi_center")
  t:put(103, 0, "signi_right")
  main(t)
  t:expect(t:action(ACT_ABILITY, center) ~= nil, "英知·遊具·トリック")
end)

case("D01-004: 클래스가 둘만이면 3체를 고를 수 없다", "WXDi-D01-004 FAQ 4 (奏像：悪魔 ≠ 精像：悪魔)", function(t)
  local center = d01(t, {"004", "005", "008"})
  signi(t, 101, {"奏像：悪魔"})
  signi(t, 102, {"精像：悪魔"})
  signi(t, 103, {"奏像：悪魔"})
  t:put(101, 0, "signi_left")
  t:put(102, 0, "signi_center")
  t:put(103, 0, "signi_right")
  main(t)
  t:expect(t:action(ACT_ABILITY, center) == nil)
end)

case("D01-004: 팀이 아니면 【チーム起】를 쓸 수 없다", "용어집: チームアイコン", function(t)
  t:lrig(30, 0, 0, {"ユヅキ"})
  local center = d01(t, {"004", "005"})
  t:put(30, 0, "lrig_assist_right")
  signi(t, 101, {"奏羅：宇宙"})
  signi(t, 102, {"奏像：武勇"})
  signi(t, 103, {"奏武：毒牙"})
  t:put(101, 0, "signi_left")
  t:put(102, 0, "signi_center")
  t:put(103, 0, "signi_right")
  main(t)
  t:expect(t:action(ACT_ABILITY, center) == nil)
end)

local function grow_to_004(t, top2)
  d01(t, {"003", "005", "008"}, {no_deck = true})
  t:fill(100, 0, "main_deck", 5)
  for _, cid in ipairs(top2) do t:put(cid, 0, "main_deck") end
  local g1, g2 = t:put(N["013"], 0, "ena"), t:put(N["013"], 0, "ena")
  local lrig = t:put(N["004"], 0, "lrig_deck")
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_GROW))
  t:expect(t:answer(lrig))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(g1, g2))
  t:expect(t:wait(HINT_MAIN))
  return lrig
end

case("D01-004: 【出】 엔나차지 2장이 공통 클래스가 없으면 1장 더", "WXDi-D01-004 【出】", function(t)
  signi(t, 101, {"奏羅：宇宙"})
  signi(t, 102, {"奏像：武勇"})
  grow_to_004(t, {101, 102})
  t:expect(t:count(0, "ena") == 3)
end)

case("D01-004: 【出】 공통 클래스가 있으면 2장만", "WXDi-D01-004 FAQ 5", function(t)
  signi(t, 101, {"英知", "遊具"})
  signi(t, 102, {"宇宙", "遊具"})
  grow_to_004(t, {101, 102})
  t:expect(t:count(0, "ena") == 2)
end)

case("D01-004: 【出】 스펠은 클래스가 없어 1장 더", "WXDi-D01-004 FAQ 3", function(t)
  signi(t, 101, {"奏羅：宇宙"})
  t:card{cid = 400, type = TYPE_SPELL}
  grow_to_004(t, {101, 400})
  t:expect(t:count(0, "ena") == 3)
end)

-- ── 006 タウィル＝ハウリング ──

local function grow_assist(t, cid, zone)
  t:expect(t:answer(t:action(ACT_GROW, cid, zone)))
end

case("D01-006: 【出】 파워 8000 이하 바니시, 1장 뽑고 1장 버린다", "WXDi-D01-006", function(t)
  d01(t, {"004", "005", "008"})
  local howl = t:put(N["006"], 0, "lrig_deck")
  t:card{cid = 110, power = 8000, level = 1}
  local target = t:put(110, 1, "signi_center")
  local h = t:put(100, 0, "hand")
  main(t)
  grow_assist(t, howl, "lrig_assist_left")
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(target))
  t:expect(t:wait(HINT_DISCARD))
  t:expect(t:answer(h))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(target, 1, "ena") and t:is_in(h, 0, "trash") and t:count(0, "hand") == 1)
end)

case("D01-006: 대상이 없어도 뽑고 버린다", "WXDi-D01-006 FAQ 1", function(t)
  d01(t, {"004", "005", "008"})
  local howl = t:put(N["006"], 0, "lrig_deck")
  t:card{cid = 110, power = 9000, level = 1}
  t:put(110, 1, "signi_center")
  main(t)
  grow_assist(t, howl, "lrig_assist_left")
  t:expect(t:wait(HINT_DISCARD))
  t:expect(not t:saw(HINT_TARGET))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 0 and t:count(0, "trash") == 1)
end)

-- ── 007 タウィル＝カラーズ ──

local function colors_setup(t)
  d01(t, {"004", "005", "008"})
  t:put(N["006"], 0, "lrig_assist_left")  -- Lv1
  local colors = t:put(N["007"], 0, "lrig_deck")
  local e = t:put(100, 0, "ena")
  return colors, e
end

case("D01-007: 적·청·녹이 있으면 위에서부터 전부", "WXDi-D01-007 FAQ 1", function(t)
  local colors, e = colors_setup(t)
  signi(t, 101, {"A"}, {color = COLOR_RED})
  signi(t, 102, {"B"}, {color = COLOR_BLUE})
  signi(t, 103, {"C"}, {color = COLOR_GREEN})
  t:put(101, 0, "signi_left")
  t:put(102, 0, "signi_center")
  t:put(103, 0, "signi_right")
  t:card{cid = 110, power = 10000, level = 1}
  local target = t:put(110, 1, "signi_center")
  main(t)
  grow_assist(t, colors, "lrig_assist_left")
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(e))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(target))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(target, 1, "ena") and t:count(0, "hand") == 2 and t:count(0, "ena") == 2)
end)

case("D01-007: 청·녹 두 색 스イギュウ 1체면 청·녹 효과만", "WXDi-D01-007 FAQ 3", function(t)
  local colors, e = colors_setup(t)
  t:put(N["018"], 0, "signi_center")
  t:put(100, 1, "signi_center")
  main(t)
  grow_assist(t, colors, "lrig_assist_left")
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(e))
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_TARGET), "적이 없어 바니시 없음")
  t:expect(t:count(0, "hand") == 2 and t:count(0, "ena") == 2)
end)

-- ── 009 ウムル＝ドロー ──

case("D01-009: 코스트 없는 【出】은 강제로 2장 뽑는다", "WXDi-D01-009 FAQ 1", function(t)
  d01(t, {"004", "005", "008"})
  local draw = t:put(N["009"], 0, "lrig_deck")
  main(t)
  grow_assist(t, draw, "lrig_assist_right")
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_USE_TRIGGER) and t:count(0, "hand") == 2)
end)

-- ── 010 ウムル＝ダウン ──

case("D01-010: 【出】 두 개 — 무료 다운, 《青》《無》를 내면 한 번 더 다운", "WXDi-D01-010", function(t)
  d01(t, {"004", "005", "008"})
  t:put(N["009"], 0, "lrig_assist_right")
  local down = t:put(N["010"], 0, "lrig_deck")
  signi(t, 101, {"A"}, {color = COLOR_BLUE})
  local blue = t:put(101, 0, "ena")
  local w1, w2 = t:put(100, 0, "ena"), t:put(100, 0, "ena")
  local a, b = t:put(100, 1, "signi_left"), t:put(100, 1, "signi_right")
  main(t)
  grow_assist(t, down, "lrig_assist_right")
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(w1))
  t:expect(t:wait(HINT_TRIGGER_ORDER), "동시에 트리거한 【出】 둘")
  t:expect(t:answer(0))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(a))
  t:expect(t:wait(HINT_USE_TRIGGER), "코스트가 있는 쪽은 임의")
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(blue, w2))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(b))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:flags(a) & CF_DOWN ~= 0 and t:flags(b) & CF_DOWN ~= 0)
end)

-- ── 012 カメロパル ──

case("D01-012: 에나 시그니 클래스 3종류 이상이면 +4000, 클래스 2개인 카드는 2종류", "WXDi-D01-012 FAQ 1·2", function(t)
  d01(t, {"004"})
  local cam = t:put(N["012"], 0, "signi_center")
  signi(t, 101, {"精生：空獣", "精生：地獣"})
  signi(t, 102, {"奏像：悪魔"})
  signi(t, 103, {"精像：悪魔"})
  t:put(101, 0, "ena")
  t:expect(t:power(cam) == 3000, "2종류")
  t:put(102, 0, "ena")
  t:expect(t:power(cam) == 7000, "3종류")
  t:move(t:cards(0, "ena")[1], 0, "trash")
  t:put(103, 0, "ena")
  t:expect(t:power(cam) == 3000, "奏像：悪魔·精像：悪魔 = 2종류")
end)

-- ── 013 センノリキュウ ──

case("D01-013: 라이프 버스트 【エナチャージ３】, 덱 2장이면 2장 놓고 끝, 그 뒤 리프레시", "WXDi-D01-013 FAQ 1", function(t)
  d01(t, {"004"}, {no_deck = true})
  t:fill(100, 0, "main_deck", 2)
  t:fill(100, 0, "trash", 5)
  t:fill(100, 0, "life_cloth", 3)
  local lb = t:put(N["013"], 0, "life_cloth")
  t:put(100, 1, "signi_center")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(t:cards(1, "signi_center")[1]))
  t:expect(t:wait(HINT_LIFEBURST))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:is_in(lb, 0, "ena") and t:count(0, "ena") == 3, "버스트 카드 + 2장")
  t:expect(t:refreshes(0) == 1)
end)

-- ── 014 スローロリス ──

case("D01-014: 【起】 파워 15000 이상 다른 시그니에 【ランサー】, 나중에 파워가 내려가도 남는다", "WXDi-D01-014 FAQ 1", function(t)
  d01(t, {"004"})
  local loris = t:put(N["014"], 0, "signi_left")
  signi(t, 101, {"A"}, {color = COLOR_GREEN})
  signi(t, 102, {"B"}, {color = COLOR_GREEN})
  signi(t, 103, {"C"}, {color = COLOR_GREEN})
  local e = {t:put(101, 0, "ena"), t:put(102, 0, "ena"), t:put(103, 0, "ena")}
  t:card{cid = 110, power = 15000, level = 1}
  local big = t:put(110, 0, "signi_center")
  t:expect(t:power(loris) == 8000, "에나 클래스 3종류: +5000")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, loris)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(e))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(big))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:keyword(big, EFFECT_LANCER))
  t:expect(t:power(loris) == 3000, "에나가 비어 +5000 없음")
  t:single(big, EFFECT_UPDATE_POWER, -5000, 1)
  t:expect(t:keyword(big, EFFECT_LANCER), "15000 아래여도 남는다")
  t:reset_phase(PHASE_END)
  t:expect(not t:keyword(big, EFFECT_LANCER), "ターン終了時まで")
end)

-- ── 015 トビエル ──

case("D01-015: 【自】 어택하면 다른 자기 시그니 +5000", "WXDi-D01-015", function(t)
  d01(t, {"004"})
  local tob = t:put(N["015"], 0, "signi_left")
  local ally = t:put(100, 0, "signi_center")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(tob))
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1, "자기 자신은 아니다")
  t:expect(t:answer(ally))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:power(ally) == 6000)
end)

local function burst_case(t, lb_no, setup_opp)
  d01(t, {"004"})
  t:fill(100, 0, "life_cloth", 3)
  local lb = t:put(N[lb_no], 0, "life_cloth")
  t:card{cid = 111, power = 3000, level = 1}
  local attacker = t:put(111, 1, "signi_right")
  local opp = setup_opp and setup_opp() or nil
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(attacker))
  t:expect(t:wait(HINT_LIFEBURST))
  t:expect(t:answer(1))
  return lb, attacker, opp
end

case("D01-015: 라이프 버스트 ① 상대 업 시그니 바니시", "WXDi-D01-015 ライフバースト", function(t)
  local _, attacker, up = burst_case(t, "015", function() return t:put(100, 1, "signi_left") end)
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(0))
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == up, "어택해서 다운된 시그니는 후보가 아니다")
  t:expect(t:answer(up))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:is_in(up, 1, "ena") and t:is_in(attacker, 1, "signi_right"))
end)

case("D01-015: 라이프 버스트 ② 1장 뽑는다", "WXDi-D01-015 ライフバースト", function(t)
  burst_case(t, "015")
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:count(0, "hand") == 1)
end)

-- ── 016 アシレン ──

local function ashiren(t, bonus)
  d01(t, {"004"})
  local a = t:put(N["016"], 0, "signi_left")
  if bonus > 0 then t:single(a, EFFECT_UPDATE_POWER, bonus, 0) end
  local h1 = t:put(100, 1, "hand")
  t:put(100, 1, "hand")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(a))
  return a, h1
end

case("D01-016: 파워 15000 이상이면 상대가 패를 1장 버린다", "WXDi-D01-016", function(t)
  local _, h1 = ashiren(t, 3000)
  t:expect(t:wait(HINT_DISCARD))
  t:expect(t:request().player == 1, "상대가 고른다")
  t:expect(t:answer(h1))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:count(1, "hand") == 1)
end)

case("D01-016: 20000 이상이면 대신 상대 패를 보지 않고 골라 버리게 한다", "WXDi-D01-016", function(t)
  local _, h1 = ashiren(t, 8000)
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:request().player == 0 and not t:can_see(0, h1))
  t:expect(t:answer(h1))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(not t:saw(HINT_DISCARD) and t:is_in(h1, 1, "trash"))
end)

case("D01-016: 15000 미만이면 아무것도 없다", "WXDi-D01-016", function(t)
  ashiren(t, 0)
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:count(1, "hand") == 2)
end)

case("D01-016: 라이프 버스트 — 시그니가 없어도 뽑는다", "WXDi-D01-016 FAQ 1", function(t)
  burst_case(t, "016")
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:count(0, "hand") == 1)
end)

-- ── 017 アタランテ ──

case("D01-017: 【出】 에나에서 서로 다른 클래스 3장 — 맞지 않는 조합은 거부", "WXDi-D01-017 FAQ 2", function(t)
  d01(t, {"004"})
  signi(t, 101, {"英知", "遊具"})
  signi(t, 102, {"宇宙", "遊具"})
  signi(t, 103, {"英知", "トリック"})
  signi(t, 104, {"英知"})
  local e1, e2, e3, e4 = t:put(101, 0, "ena"), t:put(102, 0, "ena"), t:put(103, 0, "ena"), t:put(104, 0, "ena")
  local e5 = t:put(104, 0, "ena")
  local ata = t:put(N["017"], 0, "hand")
  t:card{cid = 110, power = 8000, level = 1}
  local target = t:put(110, 1, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, ata, "signi_center")))
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_SELECT))
  local ok = t:answer(e1, e4, e5)
  t:expect(not ok, "英知·英知·遊具는 셋에 다른 클래스를 맞출 수 없다")
  t:expect(t:answer(e1, e2, e3), "英知·遊具·トリック")
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(target))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(target, 1, "ena") and t:is_in(e4, 0, "ena") and t:is_in(e5, 0, "ena") and t:count(0, "trash") == 3)
end)

case("D01-017: 맞는 3장이 없으면 발동하지 않는다", "WXDi-D01-015 FAQ 1(코스트 부족)", function(t)
  d01(t, {"004"})
  signi(t, 101, {"英知"})
  t:put(101, 0, "ena")
  t:put(101, 0, "ena")
  t:put(101, 0, "ena")
  local ata = t:put(N["017"], 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, ata, "signi_center")))
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_USE_TRIGGER))
end)

-- ── 020 サーバント　# ──

case("D01-020: 【マルチエナ】로 아무 색이나 낸다", "WXDi-D01-020, 용어집: マルチエナ", function(t)
  d01(t, {"004"})
  t:card{cid = 400, type = TYPE_SPELL, cost = "{R}"}
  t:script(400, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  c:RegisterEffect(e1)
end
]])
  local sp = t:put(400, 0, "hand")
  t:put(N["020"], 0, "ena")
  main(t)
  t:expect(t:action(ACT_USE, sp) ~= nil)
end)

-- ── 021 複成 ──

local function fukusei(t, lrigs)
  d01(t, lrigs)
  signi(t, 101, {"A"}, {color = COLOR_GREEN})
  local pay, green, white = t:put(101, 0, "ena"), t:put(101, 0, "ena"), t:put(100, 0, "ena")
  local sp = t:put(N["021"], 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(pay))
  t:expect(t:wait(HINT_TARGET))
  return pay, green, white
end

case("D01-021: 에나의 녹 시그니를 패로. 코스트로 낸 카드는 고를 수 없다", "WXDi-D01-021 FAQ 1", function(t)
  local pay, green, white = fukusei(t, {"004"})
  local o = t:request().options
  t:expect(#o == 1 and o[1] == green)
  t:expect(t:answer(green))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(green, 0, "hand") and t:is_in(pay, 0, "trash") and t:is_in(white, 0, "ena"))
end)

case("D01-021: アンシエント・サプライズ 3체면 대신 아무 시그니나", "WXDi-D01-021", function(t)
  local _, green, white = fukusei(t, {"004", "005", "008"})
  t:expect(#t:request().options == 2)
  t:expect(t:answer(white))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(white, 0, "hand") and t:is_in(green, 0, "ena"))
end)

-- ── 011 ハーモニー・コール ──

local function harmony(t, opts)
  opts = opts or {}
  d01(t, opts.lrigs or {"004", "006", "009"}, {no_deck = true})
  t:fill(100, 0, "main_deck", 4)
  signi(t, 121, {"A"}, {level = 1})
  signi(t, 122, {"B"}, {level = 2})
  signi(t, 123, {"C"}, {level = 3})
  local s1, s2, s3 = t:put(121, 0, "main_deck"), t:put(122, 0, "main_deck"), t:put(123, 0, "main_deck")
  t:card{cid = 401, type = TYPE_SPELL}
  t:fill(401, 0, "main_deck", 5)  -- 위 8장 = 스펠 5 + s3 s2 s1
  t:fill(100, 0, "ena", 8)
  local piece = t:put(N["011"], 0, "lrig_deck")
  return piece, s1, s2, s3
end

case("D01-011: 8장을 보고 Lv1·2·3을 1장씩 내고, 셋에 키워드를 준다", "WXDi-D01-011", function(t)
  local piece, s1, s2, s3 = harmony(t)
  main(t)
  local act = t:action(ACT_USE, piece)
  t:expect(act ~= nil, "팀 + 전원 Lv1 이상")
  t:expect(t:answer(act))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(t:cards(0, "ena")))
  local zones = {"signi_left", "signi_center", "signi_right"}
  for i, s in ipairs({s1, s2, s3}) do
    t:expect(t:wait(HINT_SELECT))
    t:expect(#t:request().options == 1)
    t:expect(t:answer(s))
    t:expect(t:wait(HINT_ZONE))
    t:expect(t:answer(t:request().options[1]))
  end
  for _, s in ipairs({s1, s2, s3}) do
    t:expect(t:wait(HINT_TARGET))
    t:expect(t:answer(s))
  end
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:keyword(s1, EFFECT_ASSASSIN) and t:keyword(s2, EFFECT_DOUBLE_CRUSH) and t:keyword(s3, EFFECT_LANCER))
  t:expect(t:is_in(piece, 0, "exclude"), "사용한 피스는 제외")
  t:expect(t:count(0, "main_deck") == 9)
end)

case("D01-011: 레벨 0 루리그가 있으면 쓸 수 없다", "WXDi-D01-011 FAQ 1 (全員レベル１以上)", function(t)
  local piece = harmony(t, {lrigs = {"004", "005", "009"}})
  main(t)
  t:expect(t:action(ACT_USE, piece) == nil)
end)

case("D01-011: 루리그가 1체면 쓸 수 없다", "용어집: ピース", function(t)
  local piece = harmony(t, {lrigs = {"004"}})
  main(t)
  t:expect(t:action(ACT_USE, piece) == nil)
end)

case("D01-011: 시그니가 2체 있으면 1체만 낼 수 있다", "WXDi-D01-011 FAQ 4", function(t)
  local piece, s1, s2 = harmony(t)
  t:put(100, 0, "signi_left")
  t:put(100, 0, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, piece)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(t:cards(0, "ena")))
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:answer(s1))
  t:expect(t:wait(HINT_ZONE))
  t:expect(#t:request().options == 1)
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:answer(s2))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:is_in(s2, 0, "main_deck"), "빈 존이 없어 못 냈다")
end)

case("D01-004: 선택 검증이 걸린 대상 선택 도중에 되돌려도 된다", "랜덤 대전 D01 seed 27에서 찾은 크래시", function(t)
  local center = d01(t, {"004", "005", "008"})
  signi(t, 101, {"奏羅：宇宙"})
  signi(t, 102, {"奏像：武勇"})
  signi(t, 103, {"奏武：毒牙"})
  t:put(101, 0, "signi_left")
  t:put(102, 0, "signi_center")
  t:put(103, 0, "signi_right")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, center)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:undo())
  t:expect(t:request().hint == HINT_MAIN)
end)
