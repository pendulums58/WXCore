-- WXK06-041 コードメイズ　バイア
-- 【自】：対戦相手のターンの間、このシグニがバニッシュされたとき、対戦相手は手札を１枚デッキの一番上に置く。
-- 【出】：対戦相手のトラッシュからカードを２枚まで対象とし、それらをデッキの一番下に置く。（置く順番は対戦相手が選ぶ）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetOperation(function(e,tp,eg)
    local h=Duel.GetMatchingGroup(nil,1-tp,LOCATION_HAND,0,nil)
    if h:GetCount()>0 then Duel.SendToDeckPosition(Duel.SelectCards(1-tp,h,1,1),1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 순서는 상대가
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_TRASH,0,2,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(1-tp,g),false) end
  end)
  c:RegisterEffect(e2)
end
