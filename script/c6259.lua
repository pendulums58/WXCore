-- WXK01-077 コードライド　ママチャ
-- 【自】：このシグニがドライブ状態になったとき、あなたのデッキの一番上を公開する。それが＜乗機＞のシグニの場合、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_DRIVE)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if x:IsSigni() and x:IsClass(0,RACE_JOUKI) then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e1)
end
