-- WDK04-012 超罠　ダイシャリン
-- 【出】：あなたのデッキの一番上を公開する。それがレベルが偶数のシグニの場合、それをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  -- 짝수 시그니가 아니면 뒷면으로 덱 위에(FAQ 1)
  e1:SetOperation(function(e,tp)
    local top=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not top then return end
    Duel.RevealCards(top)
    if top:IsSigni() and aux.RefLevel(tp,top)%2==0 then Duel.SendToEna(top) end
  end)
  c:RegisterEffect(e1)
end
