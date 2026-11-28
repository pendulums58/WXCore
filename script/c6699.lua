-- WXK06-084 幻竜　ギヴル
-- 【出】手札を１枚捨て、デッキの一番上のカードをトラッシュに置く：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－3000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    local d=Duel.GetDecktopGroup(tp,1)
    if chk==0 then return h:GetCount()>0 and d:GetCount()>0 end
    Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_COST+REASON_DISCARD)
    Duel.SendToTrash(Duel.GetDecktopGroup(tp,1),REASON_COST)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-3000)
    end
  end)
  c:RegisterEffect(e1)
end
