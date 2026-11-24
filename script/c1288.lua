-- WD16-023 ＨＡＮＤ　ＳＨＯＣＫ
-- このスペルの使用コストは対戦相手の手札１枚につき《無×1》増える。
-- 対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手は手札を１枚捨てる。②対戦相手のシグニ１体を対象とし、対戦相手の手札が０枚の場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- 늘어난 코스트는 《コードハート　Ｖ・Ａ・Ｃ》로 줄지 않는다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return base..string.rep("{C}",s.hand(tp)) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then
      aux.Discard(1-tp,1)
      return
    end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc and s.hand(tp)==0 then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
function s.hand(tp) return Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil):GetCount() end
