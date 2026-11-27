-- WX15-029 モアコイン・サルベージ
-- ベット―《コインアイコン》《コインアイコン》
-- あなたのトラッシュからあなたのセンタールリグと共通する色を持つシグニ１枚を対象とし、それを手札に加える。あなたがベットしていた場合、代わりにあなたのセンタールリグと共通する色を持つシグニ２枚を対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local n=Duel.IsBet() and 2 or 1
    Duel.SelectTarget(tp,function(x) local lc=Duel.GetMatchingGroup(nil,x:GetOwner(),LOCATION_LRIG,0,nil):GetFirst() return x:IsSigni() and lc and x:GetColor()&lc:GetColor()~=0 end,tp,LOCATION_TRASH,0,n,n,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e1)
end
