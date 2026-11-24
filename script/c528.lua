-- WD18-007 試行錯誤
-- ベット―《コインアイコン》《コインアイコン》
-- あなたのエナゾーンから緑のカードを３枚まで対象とし、それらを手札に加える。あなたがベットしていた場合、追加で手札から緑のシグニを３枚まで場に出す。それらのシグニの【出】能力は発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsColor(COLOR_GREEN) end,tp,LOCATION_ENA,0,0,3,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
    if not Duel.IsBet() then return end
    -- 방금 패에 넣은 시그니도 낼 수 있다
    local hand=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_GREEN) end,tp,LOCATION_HAND,0,nil)
    for tc in Duel.SelectCards(tp,hand,0,3):Iter() do Duel.PutOnField(tc,tp,true) end
  end)
  c:RegisterEffect(e1)
end
