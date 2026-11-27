-- WX18-066 羅星　≡ノベアン≡
-- 【常】：このカードがデッキか手札かトラッシュにあるかぎり、あなたの能力か効果１つによってこのシグニのレベルを参照する場合、１～４いずれかのレベル１つとして扱ってもよい。
-- 【出】：あなたのデッキの一番上を公開する。その後、対戦相手のパワー8000以下のシグニ１体を対象とし、そのカードがレベル４のシグニの場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
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
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=8000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(Group.CreateGroup(x))
    local hit=(function(x) return x:IsSigni() and aux.RefLevel(tp,x)==4 end)(x)
    local tc=Duel.GetFirstTarget()
    if hit and tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
