-- WXK06-060 ＧＦ　カンテラ
-- 【自】：このシグニがアタックしたとき、手札からレベル３以下の＜英知＞のシグニを１枚捨ててもよい。その後、この方法で捨てたシグニと同じレベルの対戦相手のシグニ１体を対象とし、それを手札に戻す。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のレベル１以下のシグニ１体を対象とし、それを手札に戻す。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    local h=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_EICHI) end)(x) and x:GetLevel()<=3 end,tp,LOCATION_HAND,0,nil)
    if h:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    local x=Duel.SelectCards(tp,h,1,1):GetFirst()
    local lv=x:GetLevel()
    if Duel.SendToTrash(x,REASON_EFFECT+REASON_DISCARD)==0 then return end
    local tc=Duel.SelectTarget(tp,function(y) return y:IsSigni() and y:GetLevel()==lv end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==1 then Duel.EnaCharge(tp,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=1 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e9)
end
