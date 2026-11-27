-- WX18-077 幻獣　シロチ
-- 【自】《ターン１回》：あなたのメインフェイズの間、このシグニのパワーが7000以上になったとき、あなたのデッキから《幻獣　シロチ》以外のレベル３以下の＜空獣＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e8=Effect.CreateEffect(c)
  e8:SetType(EFFECT_TYPE_SINGLE)
  e8:SetCode(EFFECT_POWER_WATCH)
  e8:SetRange(LOCATION_SZONE)
  e8:SetValue(7000)
  c:RegisterEffect(e8)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_POWER_REACHED)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and Duel.GetPhase()==PHASE_MAIN end)
  e1:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU)) end)(c) and c:GetLevel()<=3 and not c:IsCardName(id) end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
