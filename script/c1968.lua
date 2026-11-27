-- WX03-017 爆砲　ペンシルロケッツ
-- 【出】《赤》《赤》 ルリグデッキから赤のアーツ１枚をルリグトラッシュに置く：対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{R}{R}")
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_ARTS) and x:IsColor(COLOR_RED) end,tp,LOCATION_LDECK,0,nil)
    if chk==0 then return g:GetCount()>0 end
    Duel.SendToLrigTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e1:SetTarget(aux.BanishPowerTarget(10000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
end
