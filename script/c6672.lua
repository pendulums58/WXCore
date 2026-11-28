-- WXK06-057 ＧＦ　ホンブツーシン
-- 【起】《ダウン》：あなたのデッキからレベル３以下の＜英知＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp,eg)
    aux.SearchToHand(tp,function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_EICHI) end)(x) and x:GetLevel()<=3 end,1)
  end)
  c:RegisterEffect(e1)
end
