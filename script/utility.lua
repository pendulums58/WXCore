-- 공용 헬퍼. 코어가 카드 스크립트보다 먼저 읽는다.
-- 같은 판정이 카드 3장 이상에 나오면 여기로 뽑는다(CLAUDE.md: 카드 스크립트 규칙).
aux = aux or {}

-- ── 효과 설명 번호(설계: 효과 설명 문자열) ──
-- desc = cid × 32 + slot. slot 0~15 = str(모드·안내), 16~30 = 능력 줄 0~14, 31 = 라이프 버스트
-- e:SetDescription(aux.Ability(id,0)) / Duel.SelectOption(tp, aux.Stringid(id,0), aux.Stringid(id,1))
function aux.Stringid(id, n) return id * 32 + n end
function aux.Ability(id, n) return id * 32 + 16 + n end
function aux.LifeBurst(id) return id * 32 + 31 end

-- ── 클래스 ──
-- 클래스는 「：」 왼쪽까지 포함한 문자열로 비교한다(＜精像：悪魔＞ ≠ ＜奏像：悪魔＞. WXDi-D01-012 FAQ 2).
-- 스펠 등 클래스가 없는 카드는 빈 목록(WXDi-D01-004 FAQ 3).

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
