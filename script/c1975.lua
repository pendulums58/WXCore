-- WX03-024 ゲット・グロウ
-- あなたのセンタールリグと同じレベルのルリグ１枚をルリグデッキからグロウコストを支払わずあなたのセンタールリグにグロウする。
-- ライフバースト：次のあなたのターンの間、あなたのルリグデッキにあるあなたのセンタールリグと完全に同一のルリグタイプを持つルリグのグロウコストは《無×0》になる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 루리그 덱은 비공개라 하지 않아도 된다. 공통 루리그 타입이 필요(FAQ 3). 다운이면 다운으로(FAQ 4)
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not lc then return end
    local lv=lc:GetLevel()
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_LRIG) and x:GetLevel()==lv end,tp,LOCATION_LDECK,0,nil)
    local x=Duel.SelectCards(tp,g,0,1):GetFirst()
    if x then Duel.GrowByEffect(x,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    -- [の間] 다음 내 턴 동안. 센터와 루리그 타입이 완전히 같은 루리그(FAQ 2)
    local now,mine=Duel.GetTurnCount(),Duel.GetTurnPlayer()==tp
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_GROW_COST_ZERO)
    e1:SetTargetRange(1,0)
    e1:SetCondition(function() return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()>now end)
    e1:SetTarget(function(e,x)
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      if not lc then return false end
      local a,b=lc:GetLrigTypes(),x:GetLrigTypes()
      if #a~=#b then return false end
      local set={}
      for _,v in ipairs(a) do set[v]=true end
      for _,v in ipairs(b) do if not set[v] then return false end end
      return true
    end)
    e1:SetReset(RESET_PHASE+PHASE_END,mine and 3 or 2)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e2)
end
