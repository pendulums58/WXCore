-- WXK05-053 羅植　ゼフィラン
-- 【常】：このシグニは中央のシグニゾーンにあるかぎり、「【自】：このシグニがアタックしたとき、同じシグニゾーンに【シード】がある場合、【エナチャージ１】をする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Stringid(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetOperation(function(e,tp)
    local z=e:GetHandler():GetZone()
    if z and Duel.GetMatchingGroup(function(x) return x:GetZone()==z end,tp,LOCATION_SEED,0,nil):GetCount()>0 then Duel.EnaCharge(tp,1) end
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsInZone("signi_center") end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
end
