-- WX18-069 羅星　≡タネガスペ≡
-- 【常】：このカードがデッキか手札かトラッシュにあるかぎり、あなたの能力か効果１つによってこのシグニのレベルを参照する場合、レベル４として扱ってもよい。
-- 【出】：あなたのデッキの一番上を公開する。それがレベル４のシグニの場合、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 「レベル４として」는 1~4 중 하나로 근사
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ANY_LEVEL)
  e1:SetRange(LOCATION_MDECK+LOCATION_HAND+LOCATION_TRASH)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(Group.CreateGroup(x))
    local hit=(function(x) return x:IsSigni() and aux.RefLevel(tp,x)==4 end)(x)
    if hit then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e2)
end
