-- WX16-Re04 激奏
-- あなたのシグニ１体を対象とし、それをバニッシュする。そうした場合、あなたのデッキの上からカードを４枚公開する。その中から＜美巧＞のシグニ１枚を手札に加えるかエナゾーンに置く。残りを好きな順番でデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) or Duel.Banish(tc)==0 then return end
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,4))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local x=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,nil),1,1):GetFirst()
    -- 예 = 패, 아니오 = 에나
    if x then if Duel.SelectYesNo(tp) then Duel.SendToHand(x) else Duel.SendToEna(x) end end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
end
