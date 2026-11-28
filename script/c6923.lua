-- WXK09-050 コードアート　Ｒ・Ｌ・Ｃ
-- 【自】：あなたのターン終了時、あなたのエナゾーンからシグニを１枚まで対象とし、それを手札に加える。
-- 【出】：以下の２つから１つを選ぶ。表記されているパワーよりパワーの高いあなたの＜電機＞のシグニ１体を対象とし、ターン終了時まで、それは選んだ能力を得る。
-- ①「【常】：対戦相手の効果によってダウンしない。」
-- ②「【常】：対戦相手の効果によって手札に戻らない。」
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp,eg)
    local x=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_ENA,0,0,1,nil):GetFirst()
    if x then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    local tc=Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) and x:GetPower()>x:GetBasePower() end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if tc then aux.GrantKeyword(e,tc,m==0 and EFFECT_NO_DOWN_BY_OPP or EFFECT_NO_BOUNCE) end
  end)
  c:RegisterEffect(e2)
end
