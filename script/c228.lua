-- WX22-Re04 験英の応援　＃ウカロー＃
-- 【常】：このシグニが場に出たターンの間、このシグニは自身の【出】能力で選んだ能力を得る。
-- 【出】：以下の３つから１つを選ぶ。
-- ①「【常】：あなたの他の＜英知＞のシグニのパワーは対戦相手の効果によって減少しない。」
-- ②「【常】：あなたの他の＜英知＞のシグニは対戦相手の効果によって場から手札に移動しない。」
-- ③「【常】：あなたの他の＜英知＞のシグニは対戦相手の効果によってバニッシュされない。」
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】·【出】 선택한 능력(그 턴 동안). 셋 다 「他の＜英知＞」에 효과로 근사
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local m=Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))[1]
    local code=({EFFECT_NO_OPP_POWER_CARD,EFFECT_NO_BOUNCE,EFFECT_BANISH_IMMUNE})[m+1]
    local h=e:GetHandler()
    local e1=Effect.CreateEffect(h)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(code)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_SZONE,0)
    e1:SetTarget(function(e2,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end)(x) and x~=h end)
    if code==EFFECT_BANISH_IMMUNE then e1:SetValue(function(e2,sc,sp) return sp~=tp end) end
    e1:SetReset(RESET_PHASE+PHASE_END)
    h:RegisterEffect(e1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e2:SetOperation(function(e,tp)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e2)
end
