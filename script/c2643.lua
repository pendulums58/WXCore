-- WX13-072 幻水　イダビウオ
-- 【自】：あなたの＜水獣＞のシグニ１体が場に出たとき、対戦相手のライフクロスの一番上を見る。（このシグニが場に出たときも発動する）
local s,id=GetID()
function s.initial_effect(c)
  -- 자신도(괄호)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end)(x) end)
  e1:SetOperation(function(e,tp)
    local l=Duel.GetMatchingGroup(nil,1-tp,LOCATION_LIFE,0,nil):GetFirst()
    if l then Duel.ConfirmCards(tp,l) end
  end)
  c:RegisterEffect(e1)
end
