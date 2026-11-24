-- WDK04-008 ブラッディ・アウト
-- ベット―《コインアイコン》《コインアイコン》
-- あなたのシグニ１体を場からトラッシュに置く。
-- そうした場合、対象の対戦相手のレベル４以下のシグニ１体をバニッシュする。あなたがベットしていた場合、追加で対象の対戦相手のシグニ１体をバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  -- 자기 시그니를 놓기 전에 둘을 같이 고른다(FAQ 1). 추가분은 레벨 제한이 없다(FAQ 2·4)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local x=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=4 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if Duel.IsBet() then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,x) end
  end)
  e1:SetOperation(function(e,tp)
    local mine=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
    if mine:GetCount()==0 or Duel.SendToTrash(Duel.SelectCards(tp,mine,1,1),REASON_EFFECT)==0 then return end
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
end
