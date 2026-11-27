-- WX15-057 コードイート　バーガー
-- 【起】《ダウン》：あなたのデッキの一番上のカードをエナゾーンに置く。それが《アクセアイコン》を持つシグニの場合、追加でカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.SendToEna(x)
    if x:IsSigni() and x:HasAcceIcon() then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
