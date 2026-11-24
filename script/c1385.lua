-- WD23-028-E 幻水　イルカ
-- 【自】：このシグニがアタックしたとき、対戦相手のデッキの一番上を見る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(1-tp,1)
    if g:GetCount()>0 then Duel.ConfirmCards(tp,g) end
  end)
  c:RegisterEffect(e1)
end
