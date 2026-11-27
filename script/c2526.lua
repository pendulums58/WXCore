-- WX11-080 羅植　シクラメン
-- 【起】《ダウン》：白、赤、青、黒から１つを選ぶ。あなたのデッキの一番上を公開し、それが選んだ色を持つシグニである場合、それをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp)
    local col=({COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_BLACK})[Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))[1]+1]
    local x=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,1)):GetFirst()
    if not x then return end
    Duel.RevealCards(x)
    if x:IsSigni() and x:IsColor(col) then Duel.SendToEna(x) end
  end)
  c:RegisterEffect(e1)
end
