-- WX21-Re04 リヴァイバル・エクシード
-- 対戦相手のターンの間、このカードの使用コストは《無》《無》《無》になる。
-- あなたのルリグのエクシードの値が３以下の能力１つをコストを支払わずに使用する。（使用タイミングを無視する）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) if Duel.GetTurnPlayer()~=tp then return "{C}{C}{C}" end return base end)
  -- 「エクシードの値が３以下の能力をコストを支払わずに使用」은 아직(근사 없음)
  e1:SetOperation(function(e,tp)
    
  end)
  c:RegisterEffect(e1)
end
