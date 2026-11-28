-- WXK03-030 讃の遊　ボールプール
-- 【自】：あなたのレベル４の＜遊具＞のシグニがアタックしたとき、《白》を支払ってもよい。そうした場合、このシグニを場から手札に戻し、手札からレベル２以下の＜遊具＞のシグニ１枚を場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:IsSigni() and x:GetLevel()==4 and x:IsClass(0,RACE_YUGU) end)
  e1:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{W}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}"),REASON_COST)
    local h=e:GetHandler()
    if not h:IsLocation(LOCATION_SZONE) or Duel.SendToHand(h)==0 then return end
    local g=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_YUGU) end)(x) and x:GetLevel()<=2 end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()>0 then Duel.PutOnField(Duel.SelectCards(tp,g,1,1):GetFirst(),tp) end
  end)
  c:RegisterEffect(e1)
end
