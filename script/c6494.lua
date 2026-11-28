-- WXK04-038 羅植　ユリ
-- 【自】《ターン１回》：このシグニがアタックしたとき、対戦相手のレベル１以下のシグニ１体を対象とし、このターンにあなたのエナゾーンに＜植物＞のシグニが１枚以上置かれていた場合、あなたのエナゾーンから＜植物＞のシグニ１枚をトラッシュに置いてもよい。そうした場合、それを手札に戻す。
local s,id=GetID()
s.plant_ena={}  -- 플레이어별: ＜植物＞가 에나에 놓인 턴(근사: 이 시그니가 장에 있는 동안만 센다)
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCountLimit(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=1 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and s.plant_ena[tp]==Duel.GetTurnCount()) then return end
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end,tp,LOCATION_ENA,0,nil)
    if g:GetCount()>0 and Duel.SelectYesNo(tp) and Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)>0 then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 이 턴에 에나에 ＜植物＞가 놓였는지 기억한다
  e2:SetCode(EVENT_TO_ENA)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) for x in eg:Iter() do if x:GetOwner()==tp and (function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end)(x) then return true end end return false end)
  e2:SetOperation(function(e,tp,eg)
    s.plant_ena[tp]=Duel.GetTurnCount()
  end)
  c:RegisterEffect(e2)
end
