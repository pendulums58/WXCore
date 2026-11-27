-- WX15-087 小罠　イテテ
-- 【トラップアイコン】：対戦相手の手札を１枚見ないで選び、捨てさせる。
-- （対戦相手のシグニがアタックしたとき、その正面にシグニがない場合、そこにある【トラップ】を表向きにし《トラップアイコン》を発動してもよい。その後トラッシュに置く）
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_TRAP)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if h:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
