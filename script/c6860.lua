-- WXK08-074 炎魔の三足　カウ
-- 【自】：このカードが【ビート】になったとき、《赤》を支払ってもよい。そうした場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BEAT)
  e1:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}"),REASON_COST)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
end
