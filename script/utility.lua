-- 공용 헬퍼. 코어가 카드 스크립트보다 먼저 읽는다.
-- 같은 판정이 카드 3장 이상에 나오면 여기로 뽑는다(CLAUDE.md: 카드 스크립트 규칙).
aux = aux or {}

-- ── 효과 설명 번호(설계: 효과 설명 문자열) ──
-- desc = cid × 32 + slot. slot 0~15 = str(모드·안내), 16~30 = 능력 줄 0~14, 31 = 라이프 버스트
-- e:SetDescription(aux.Ability(id,0)) / Duel.SelectOption(tp, aux.Stringid(id,0), aux.Stringid(id,1))
function aux.Stringid(id, n) return id * 32 + n end
function aux.Ability(id, n) return id * 32 + 16 + n end
function aux.LifeBurst(id) return id * 32 + 31 end

-- ── 덱 ──

-- 「デッキから…を（N枚まで）探して公開し手札に加え、デッキをシャッフルする」.
-- 덱을 전부 보고, 맞는 카드를 0~max장 골라 공개하고 패에, 그다음 섞는다. 있어도 찾지 않았다고 할 수 있다(용어집: 探す). 패에 넣은 묶음
function aux.SearchToHand(tp, filter, max)
  Duel.ConfirmCards(tp, Duel.GetMatchingGroup(nil, tp, LOCATION_MDECK, 0, nil))
  local g = Duel.SelectCards(tp, Duel.GetMatchingGroup(filter, tp, LOCATION_MDECK, 0, nil), 0, max)
  if g:GetCount() > 0 then
    Duel.RevealCards(g)
    Duel.SendToHand(g)
  end
  Duel.SendToDeckShuffle(Group.CreateGroup(), tp)
  return g
end

-- 「それらを好きな順番でデッキの一番上に戻す」: 고른 순서대로 덱 위에(처음 고른 카드가 맨 위)
function aux.ToDeckTopInOrder(tp, g)
  local list = {}
  for c in Duel.SelectOrder(tp, g):Iter() do list[#list + 1] = c end
  for i = #list, 1, -1 do Duel.SendToDeckPosition(list[i], 1) end
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
