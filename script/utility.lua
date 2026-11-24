-- 공용 헬퍼. 코어가 카드 스크립트보다 먼저 읽는다.
-- 같은 판정이 카드 3장 이상에 나오면 여기로 뽑는다(CLAUDE.md: 카드 스크립트 규칙).
aux = aux or {}

-- ── 효과 설명 번호(설계: 효과 설명 문자열) ──
-- desc = cid × 32 + slot. slot 0~15 = str(모드·안내), 16~30 = 능력 줄 0~14, 31 = 라이프 버스트
-- e:SetDescription(aux.Ability(id,0)) / Duel.SelectOption(tp, aux.Stringid(id,0), aux.Stringid(id,1))
function aux.Stringid(id, n) return id * 32 + n end
function aux.Ability(id, n) return id * 32 + 16 + n end
function aux.LifeBurst(id) return id * 32 + 31 end

-- ── 파워 ──

-- 「ターン終了時まで、それのパワーを＋N/－Nする」: tc에 턴 종료 시까지 파워 v. 대상 고정([まで]). 만든 효과를 돌려준다
function aux.AddPower(e, tc, v)
  local e1 = Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetValue(v)
  e1:SetReset(RESET_PHASE + PHASE_END)
  tc:RegisterEffect(e1)
  return e1
end

-- 「あなたの場に他の＜X＞のシグニがあるかぎり、このシグニの基本パワーは N になる」: [の間] 【常】.
-- 기본 파워라 다른 ±는 그 위에 더해진다. race는 種族 상수(RACE_*)
function aux.BasePowerWhileClass(c, race, power)
  return aux.BasePower(c, power, function(e)
    return Duel.GetMatchingGroup(aux.ClassFilter(0, race), e:GetHandlerPlayer(), LOCATION_SIGNI, 0, e:GetHandler()):GetCount() > 0
  end)
end

-- 「(…かぎり)このシグニの基本パワーは N になる」: [の間] 【常】. con(e) → bool, 없으면 항상
function aux.BasePower(c, power, con)
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_SET_BASE_POWER)
  e1:SetRange(LOCATION_SZONE)
  if con then e1:SetCondition(con) end
  e1:SetValue(power)
  c:RegisterEffect(e1)
  return e1
end

-- ── 레조나(용어집: レゾナ, 出現条件) ──

-- 「【出現条件】《…アイコン》 …をN体あなたの場からトラッシュに置く」. 출현 조건은 코스트도 효과도 아니다.
-- filter(c) → bool: 출현 조건이 될 카드. loc 기본 = 자기 장의 시그니. timing 기본 = TIMING_MAIN
-- 레벨·리미트(출현 조건으로 떠나는 시그니는 빼고 센다)·한정 조건은 코어가 본다
-- 장수가 여러 가지면 min(n은 최대)과 조합 검증 check(g) → bool을 준다.
-- 【出】의 ev = 출현 조건으로 트래시한 시그니의 레벨 합계
function aux.AddResonaProc(c, n, filter, loc, timing, min, check)
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_RESONA)
  e1:SetRange(LOCATION_LDECK)
  e1:SetValue(n)
  e1:SetTargetRange(loc or LOCATION_SZONE, 0)
  e1:SetTarget(function(e, x) return filter(x) end)
  e1:SetTiming(timing or TIMING_MAIN)
  if min then e1:SetLabel(min) end
  if check then e1:SetCheck(check) end
  c:RegisterEffect(e1)
  return e1
end

-- 「レゾナではない＜X＞のシグニ」
function aux.NonResonaClass(race)
  return function(x) return x:IsSigni() and not x:IsType(TYPE_RESONA) and x:IsClass(0, race) end
end

-- ── 라이즈(용어집: ライズ) ──

-- 「【ライズ】あなたの…のシグニ１体の上に置く」: filter(c) → bool, 밑이 될 자기 시그니. 효과로 낼 때도 이 조건을 채워야 한다
function aux.AddRise(c, filter)
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_RISE)
  if filter then e1:SetTarget(function(e, x) return filter(x) end) end
  c:RegisterEffect(e1)
  return e1
end

-- ── 英知 ──

-- 「英知=N」: 자기 장의 ＜英知＞ 시그니 레벨 합계가 꼭 n인 동안 유효. e:SetCondition(aux.EichiCon(7))
function aux.EichiCon(n)
  return function(e)
    local sum = 0
    for x in Duel.GetMatchingGroup(aux.ClassFilter(0, RACE_EICHI), e:GetHandlerPlayer(), LOCATION_SZONE, 0, nil):Iter() do
      sum = sum + x:GetLevel()
    end
    return sum == n
  end
end

-- ── 악세(용어집: アクセ) ──

-- 《アクセアイコン》 「【起】(코스트)：あなたのシグニ１体を対象とし、このカードをエナゾーンからそれの【アクセ】にする。」
-- desc = aux.Ability(id,n). cost가 없으면 《緑×0》. 자신을 에나 코스트로 내면 붙일 수 없다(WD18-013 FAQ 2)
function aux.AddAcce(c, desc, cost)
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_ACCE)
  c:RegisterEffect(e1)
  local e2 = Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(desc)
  e2:SetRange(LOCATION_ENA)
  if cost then e2:SetEnaCost(cost) end
  e2:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SelectTarget(tp, Card.IsSigni, tp, LOCATION_SZONE, 0, 1, 1, nil)
  end)
  e2:SetOperation(function(e, tp)
    local tc, h = Duel.GetFirstTarget(), e:GetHandler()
    if tc and tc:IsRelateToEffect(e) and h:IsLocation(LOCATION_ENA) then Duel.Acce(h, tc) end
  end)
  c:RegisterEffect(e2)
  return e2
end

-- ── 크로스(용어집: クロス条件) ──

-- 「《クロスアイコン》《X》の右／左」: cid = 짝(동명이 갈리면 대표 cid), side = CROSS_RIGHT/CROSS_LEFT. 여러 번 부르면 「か」
function aux.AddCross(c, cid, side)
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_CROSS)
  e1:SetValue(cid)
  e1:SetLabel(side)
  c:RegisterEffect(e1)
  return e1
end

-- ── 코스트 ──

-- 사용(그로우) 코스트를 f(e,tp,base) → 코스트 문자열로 정한다. base = 다른 카드의 감소까지 뺀 코스트.
-- f는 무엇이든 볼 수 있다(장·패·트래시·에나·턴). 카드를 고르거나 버리며 정하는 것은 SetMinCost·SetDeclare를 직접 쓴다
function aux.SetCostBy(e, f)
  e:SetMinCost(f)
  e:SetDeclare(function(e, tp) Duel.SetUseCost(f(e, tp, Duel.GetUseCost())) end)
end

-- 「《ダウン》」: 업 상태의 자신을 다운한다. e:SetCost(aux.SelfDownCost)
function aux.SelfDownCost(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then return e:GetHandler():IsUp() end
  Duel.Down(e:GetHandler())
end

-- 「手札を(…を)N枚捨てる」 코스트. e:SetCost(aux.DiscardCost(1,filter)). filter(c)는 없어도 된다
function aux.DiscardCost(n, filter)
  return function(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetMatchingGroup(filter, tp, LOCATION_HAND, 0, nil):GetCount() >= n end
    Duel.SendToTrash(Duel.SelectDiscard(tp, n, n, filter), REASON_COST + REASON_DISCARD)
  end
end

-- ── 능력 부여 ──

-- 「ターン終了時まで、それは【…】を得る」·「アタックできない」: 카드가 얻는 능력. 대상 고정([まで]). reset 기본 = 턴 종료 시
function aux.GrantKeyword(e, tc, code, reset)
  local e1 = Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(code)
  e1:SetReset(reset or RESET_PHASE + PHASE_END)
  tc:GrantEffect(e1)
  return e1
end

-- ── 바니시 ──

-- 「対戦相手のパワーN以下のシグニ１体を対象とし」 대상 지정. 파워는 대상으로 고를 때 본다. e:SetTarget(aux.BanishPowerTarget(8000))
function aux.BanishPowerTarget(n)
  return function(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SelectTarget(tp, function(c) return c:IsSigni() and c:GetPower() <= n end, tp, 0, LOCATION_SZONE, 1, 1, nil)
  end
end

-- 「それをバニッシュする」 처리. e:SetOperation(aux.BanishOp)
function aux.BanishOp(e, tp)
  local tc = Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
end

-- ── 에나 ──

-- 「【エナチャージＮ】」·「デッキの上からカードをＮ枚エナゾーンに置く」 처리 함수. 조건은 효과 쪽에서 SetCondition으로 붙인다
function aux.EnaChargeOp(n)
  return function(e, tp) Duel.EnaCharge(tp, n) end
end

-- ── 덱 ──

-- 「デッキから…を（N枚まで）探して」: 덱을 전부 보고 맞는 카드를 0~max장 고른다. 있어도 찾지 않았다고 할 수 있다(용어집: 探す).
-- 고른 묶음만 돌려준다. 어디에 놓을지와 셔플(aux.ShuffleDeck)은 부른 쪽이 한다
function aux.Search(tp, filter, max)
  Duel.ConfirmCards(tp, Duel.GetMatchingGroup(nil, tp, LOCATION_MDECK, 0, nil))
  return Duel.SelectCards(tp, Duel.GetMatchingGroup(filter, tp, LOCATION_MDECK, 0, nil), 0, max)
end

-- 「デッキをシャッフルする」
function aux.ShuffleDeck(tp) Duel.SendToDeckShuffle(Group.CreateGroup(), tp) end

-- 「デッキから…を（N枚まで）探して公開し手札に加え、デッキをシャッフルする」.
-- 덱을 전부 보고, 맞는 카드를 0~max장 골라 공개하고 패에, 그다음 섞는다. 있어도 찾지 않았다고 할 수 있다(용어집: 探す). 패에 넣은 묶음
function aux.SearchToHand(tp, filter, max)
  local g = aux.Search(tp, filter, max)
  if g:GetCount() > 0 then
    Duel.RevealCards(g)
    Duel.SendToHand(g)
  end
  aux.ShuffleDeck(tp)
  return g
end

-- 「デッキの上からカードをN枚公開し(見て)、その中から…をmin~max枚手札に加え」. hidden이면 자기만 본다(filter가 있으면 고른 카드는 공개).
-- 나머지는 부른 쪽이 옮긴다: local picked,rest=aux.ExcavateToHand(tp,5,filter,0,1)  Duel.SendToTrash(rest,REASON_EFFECT)
function aux.ExcavateToHand(tp, n, filter, min, max, hidden)
  local g = Duel.GetDecktopGroup(tp, n)
  if g:GetCount() == 0 then return g, Group.CreateGroup() end
  if hidden then Duel.ConfirmCards(tp, g) else Duel.RevealCards(g) end
  local sg = Duel.SelectCards(tp, filter and g:Filter(filter, nil) or g, min, max)
  local rest = g:Filter(function(x) return not sg:IsContains(x) end, nil)
  if sg:GetCount() > 0 then
    if hidden and filter then Duel.RevealCards(sg) end
    Duel.SendToHand(sg)
  end
  return sg, rest
end

-- ── 패 ──

-- 「(플레이어 p는) 手札をN枚捨てる」: p가 고른다. 모자라면 있는 만큼. 버린 장수
function aux.Discard(p, n)
  n = math.min(n, Duel.GetMatchingGroup(nil, p, LOCATION_HAND, 0, nil):GetCount())
  if n <= 0 then return 0 end
  return Duel.SendToTrash(Duel.SelectDiscard(p, n, n), REASON_EFFECT + REASON_DISCARD)
end

-- 「手札から…をN枚公開する」: 0장 또는 N장(패는 비공개 영역이라 공개하지 않아도 된다. WDK08-Y01 FAQ 3).
-- n이 nil이면 「好きな枚数」(0장~전부). 공개한 묶음(안 했으면 빈 묶음)
function aux.RevealFromHand(tp, filter, n)
  local g = Duel.GetMatchingGroup(filter, tp, LOCATION_HAND, 0, nil)
  if n and g:GetCount() < n then return Group.CreateGroup() end
  if n then Duel.SetSelectCheck(function(sg) return sg:GetCount() == 0 or sg:GetCount() == n end) end
  local sg = Duel.SelectCards(tp, g, 0, n or g:GetCount())
  if sg:GetCount() == 0 then return sg end
  Duel.RevealCards(sg)
  return sg
end

-- 「それらを好きな順番でデッキの一番上に戻す」: 고른 순서대로 덱 위에(처음 고른 카드가 맨 위)
function aux.ToDeckTopInOrder(tp, g)
  local list = {}
  for c in Duel.SelectOrder(tp, g):Iter() do list[#list + 1] = c end
  for i = #list, 1, -1 do Duel.SendToDeckPosition(list[i], 1) end
end

-- 「好きな順番でライフクロスの一番上に戻す」: 처음 고른 카드가 맨 위. 라이프 클로스 안의 순서만 바뀌어 「加えられた」가 아니다(WD06-007 FAQ 2)
function aux.ToLifeTopInOrder(tp, g)
  local list = {}
  for c in Duel.SelectOrder(tp, g):Iter() do list[#list + 1] = c end
  for i = #list, 1, -1 do Duel.SendToLife(list[i]) end
end

function aux.BloodArm(tp, c, loc)
  local g = Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsSameName(c) and x ~= c end, tp, loc, 0, nil)
  local hidden = loc == LOCATION_HAND or loc == LOCATION_MDECK
  if loc == LOCATION_MDECK then Duel.ConfirmCards(tp, Duel.GetMatchingGroup(nil, tp, LOCATION_MDECK, 0, nil)) end
  local pick = Duel.SelectCards(tp, g, hidden and 0 or math.min(1, g:GetCount()), 1):GetFirst()
  local ok = pick ~= nil and Duel.BloodArm(c, pick)
  if loc == LOCATION_MDECK then Duel.SendToDeckShuffle(Group.CreateGroup(), tp) end
  return ok
end

-- ── 클래스 ──
-- 클래스는 (系統, 種族) 쌍의 코드다(系統 << 16 | 種族). 상수 SYS_*·RACE_*·LRIG_*는 classes.lua(카드 DB의 classes 표).
-- c:GetClasses()는 코드 목록이라 좌우가 다 같아야 같은 클래스다(＜精像：悪魔＞ ≠ ＜奏像：悪魔＞. WXDi-D01-012 FAQ 2).
-- 스펠 등 클래스가 없는 카드는 빈 목록(WXDi-D01-004 FAQ 3).

-- 클래스 코드 하나. EFFECT_ADD_CLASS 값 등: e:SetValue(aux.Class(SYS_SEIGEN, 0))
function aux.Class(sys, race) return sys * 65536 + race end

-- 「＜…＞のシグニ」 필터. 0은 「아무거나」: aux.ClassFilter(0, RACE_YUGU)는 ＜遊具＞(精武·奏武 둘 다),
-- aux.ClassFilter(SYS_SEIZOU, 0)은 ＜精像＞(WX20-007, 奏像은 아니다)
function aux.ClassFilter(sys, race)
  return function(c) return c:IsSigni() and c:IsClass(sys, race) end
end

-- 묶음 안의 서로 다른 클래스 수(「クラスが合計３種類以上」. WXDi-D01-012 FAQ 1: 클래스 2개인 카드는 2종류)
function aux.ClassCount(g)
  local seen, n = {}, 0
  for c in g:Iter() do
    for _, cls in ipairs(c:GetClasses()) do
      if not seen[cls] then
        seen[cls] = true
        n = n + 1
      end
    end
  end
  return n
end

-- 「それぞれ異なるクラスを持つ」: 카드마다 서로 다른 클래스를 하나씩 맞출 수 있는가(이분 매칭).
-- ＜英知/遊具＞·＜宇宙/遊具＞·＜英知/トリック＞ 셋은 된다(WXDi-D01-004 FAQ 5, WXDi-D01-017 FAQ 2)
function aux.DistinctClasses(g)
  local cards = {}
  for c in g:Iter() do cards[#cards + 1] = c:GetClasses() end
  local owner = {}  -- 클래스 → 카드 번호
  local function try(i, visited)
    for _, cls in ipairs(cards[i]) do
      if not visited[cls] then
        visited[cls] = true
        if owner[cls] == nil or try(owner[cls], visited) then
          owner[cls] = i
          return true
        end
      end
    end
    return false
  end
  for i = 1, #cards do
    if not try(i, {}) then return false end
  end
  return true
end

-- 「共通するクラスを持たない」: 어느 두 장도 같은 클래스를 갖지 않는다(WXDi-D01-004 FAQ 5)
function aux.NoCommonClass(g)
  local seen = {}
  for c in g:Iter() do
    for _, cls in ipairs(c:GetClasses()) do
      if seen[cls] then return false end
      seen[cls] = true
    end
  end
  return true
end
