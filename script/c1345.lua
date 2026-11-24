-- WD22-016-UG バッド・エクシード
-- あなたのトラッシュからシグニを２枚まで対象とし、あなたのセンタールリグの下からカード４枚をルリグトラッシュに置く。そうした場合、それらを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  -- 4장이 안 되면 1장도 놓지 않는다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local g=lc and lc:GetUnderGroup()
    if not g or g:GetCount()<4 or Duel.SendToLrigTrash(Duel.SelectCards(tp,g,4,4))<4 then return end
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
    end
  end)
  c:RegisterEffect(e1)
end
