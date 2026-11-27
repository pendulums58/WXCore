-- WX02-029 宝具　ミツルギ
-- 【出】手札から＜アーム＞か＜ウェポン＞のシグニを１枚捨てる：あなたのデッキからシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM) or x:IsClass(0,RACE_WEAPON)) end))
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,Card.IsSigni,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
