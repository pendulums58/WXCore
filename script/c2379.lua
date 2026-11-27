-- WX09-CB01 コードアート　Ｈ・Ｔ・Ｒ
-- 【自】：このシグニがアタックしたとき、手札から＜電機＞のシグニを１枚捨ててもよい。そうした場合、以下の３つから１つを選ぶ。
-- ①カードを２枚引く。
-- ②対戦相手の凍結状態のシグニ１体を対象とし、それをバニッシュする。
-- ③対戦相手の手札を１枚見ないで選び、捨てさせる。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI)) end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    if Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD)==0 then return end
    local m=Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))[1]
    if m==0 then
      Duel.Draw(tp,2)
    elseif m==1 then
      local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsFrozen() end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    else
      local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
      if h:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
