-- WXK04-059 奪取
-- 対象の対戦相手のシグニ１体をエナゾーンに置く。あなたのトラッシュから対象の＜水獣＞のシグニ１枚を手札に加え、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    for x in Duel.GetTargets():Iter() do
      if x:IsRelateToEffect(e) then
        if x:IsLocation(LOCATION_SZONE) then Duel.SendToEna(x) else Duel.SendToHand(x) end
      end
    end
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
end
