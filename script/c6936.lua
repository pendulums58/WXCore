-- WXK09-063 パペット・ショー
-- このスペルは手札以外から使用できない。
-- 対戦相手のトラッシュからシグニ１枚を対象とし、それを傀儡状態であなたの場に出す。その後、あなたの場に傀儡状態のシグニが２体以上ある場合、【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  -- 「手札以外から使用できない」
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_HAND) or e:GetHandler():IsLocation(LOCATION_HAND) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_TRASH,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsPuppet() end,tp,LOCATION_SZONE,0,nil):GetCount()>=2 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
end
