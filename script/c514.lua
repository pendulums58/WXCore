-- WDK01-009 剣抜弩焼
-- このアーツはあなたのセンタールリグが赤の場合にしか使用できない。
-- 対戦相手のシグニ１体を対象とし、それをバニッシュする。手札を２枚捨てる。（手札が１枚以下で使用した場合すべて捨てる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    return lc~=nil and lc:IsColor(COLOR_RED)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  -- 대상이 없어도, 바니시하지 못해도 버린다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    aux.Discard(tp,2)
  end)
  c:RegisterEffect(e1)
end
