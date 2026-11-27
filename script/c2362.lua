-- WX09-038 中剣　ライキリ
-- 【起】《ダウン》手札から＜アーム＞のシグニを１枚捨てる：あなたのデッキからレベル３以下の白のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return h:IsUp() and g:GetCount()>0 end
    Duel.Down(h,REASON_COST)
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST+REASON_DISCARD)
  end)
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) and x:GetLevel()<=3 end,1)
  end)
  c:RegisterEffect(e1)
end
