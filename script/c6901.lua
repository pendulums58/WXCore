-- WXK09-028 戦倶の蒼天　アークゲイン
-- 【常】：対戦相手の手札が１枚以下であるかぎり、あなたの＜天使＞のシグニは対戦相手のシグニの効果を受けない。
-- 【自】：あなたのアタックフェイズ開始時、あなたのトラッシュに＜天使＞のシグニが１５枚以上ある場合、カードを１枚引く。
-- 【出】手札から＜天使＞のシグニを１枚捨てる：対戦相手は手札を１枚捨てる。
-- ライフバースト：対象の対戦相手のシグニ１体をダウンする。あなたのトラッシュから対象の＜天使＞のシグニ１枚を手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end)(x) end)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,1-e:GetHandlerPlayer(),LOCATION_HAND,0,nil):GetCount()<=1 end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsSigni() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end,tp,LOCATION_TRASH,0,nil):GetCount()>=15 end)
  e2:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end))
  e3:SetOperation(function(e,tp,eg)
    aux.Discard(1-tp,1)
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    local a=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    local b=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if a then Duel.Down(a) end
    if b then Duel.SendToHand(b) end
  end)
  c:RegisterEffect(e9)
end
