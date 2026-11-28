-- WXK09-064 波翔の蒼天　ネプトゥーヌス
-- 【起】《青》《ダウン》：対戦相手のシグニ１体を対象とし、あなたのトラッシュに＜天使＞のシグニが１５枚以上ある場合、それをデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetEnaCost("{U}")
  e1:SetCost(aux.SelfDownCost)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end,tp,LOCATION_TRASH,0,nil):GetCount()>=15 then Duel.SendToDeckPosition(tc,1) end
    end
  end)
  c:RegisterEffect(e1)
end
