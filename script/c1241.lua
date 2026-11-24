-- WD13-017 忘得ぬ幻想　ヴァルキリー
-- 【起】《ダウン》：あなたのデッキから《忘得ぬ幻想　ヴァルキリー》以外のレベル３以下のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 and x:GetCode()~=id end,1)
  end)
  c:RegisterEffect(e1)
end
