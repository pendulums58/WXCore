-- WXK06-036 ＧＦ　ウーゴ冒険記
-- 【自】：このシグニがアタックしたとき、このシグニを場から手札に戻してもよい。そうした場合、あなたの手札からレベル３の＜英知＞のシグニ１枚を場に出す。そのシグニの【出】能力は発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) or Duel.SendToHand(h)==0 then return end
    local g=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_EICHI) end)(x) and x:GetLevel()==3  end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()>0 then Duel.PutOnField(Duel.SelectCards(tp,g,1,1):GetFirst(),tp,true) end
  end)
  c:RegisterEffect(e1)
end
