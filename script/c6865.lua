-- WXK08-079 弩書　ダイヨン
-- 【出】：あなたのトラッシュからシグニ２枚を対象とし、それらをこのシグニの下に置く。
-- （コストのない【出】能力は発動しないことを選べない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,2,2,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if h:IsLocation(LOCATION_SZONE) and g:GetCount()>0 then Duel.PutUnder(h,g) end
  end)
  c:RegisterEffect(e1)
end
