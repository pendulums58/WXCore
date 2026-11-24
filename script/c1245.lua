-- WD13-021 探求の思想　ハニエル
-- 【起】《ダウン》手札を１枚捨てる：あなたのデッキからレベル２以下の白のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsUp() and Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()>=1 end
    Duel.Down(e:GetHandler())
    Duel.SendToTrash(Duel.SelectDiscard(tp,1,1),REASON_COST+REASON_DISCARD)
  end)
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) and x:GetLevel()<=2 end,1)
  end)
  c:RegisterEffect(e1)
end
