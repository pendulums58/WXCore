-- WXK06-070 コードメイズ　ロイヤル
-- 【自】：このシグニがアタックしたとき、このターンに対戦相手のカードがあなたの効果によって２枚以上デッキに移動していた場合、あなたのデッキから青のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    if Duel.GetDeckMovedCount(tp)>=2 then aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLUE) end,1) end
  end)
  c:RegisterEffect(e1)
end
