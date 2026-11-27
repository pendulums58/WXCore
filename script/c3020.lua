-- WX18-070 羅星　≡スペースパ≡
-- 【自】：このシグニがアタックしたとき、あなたのデッキの一番上を公開する。それがレベル４のシグニの場合、それをあなたのエナゾーンに置くか手札に加える。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(Group.CreateGroup(x))
    local hit=(function(x) return x:IsSigni() and aux.RefLevel(tp,x)==4 end)(x)
    if hit then if Duel.SelectYesNo(tp) then Duel.SendToEna(x) else Duel.SendToHand(x) end end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
