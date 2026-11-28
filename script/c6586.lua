-- WXK05-044 幻水　プテリゴ
-- 【出】《緑》：あなたの手札からレベル３以上の＜水獣＞のシグニ１枚を公開する。そうした場合、あなたのデッキからこの方法で公開したシグニと同じ名前のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{G}")
  e1:SetOperation(function(e,tp,eg)
    local g=aux.RevealFromHand(tp,function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end)(x) and x:GetLevel()>=3 end,1)
    local x=g:GetFirst()
    if x then aux.SearchToHand(tp,function(y) return y:IsSigni() and y:IsSameName(x) end,1) end
  end)
  c:RegisterEffect(e1)
end
