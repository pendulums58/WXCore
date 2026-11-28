-- WXEX1-62 羅星　ケプリ
-- 【常】：このカードがデッキか手札かトラッシュにあるかぎり、あなたの効果１つによってこのシグニのレベルを参照する場合、レベル４として扱ってもよい。
-- 【自】：このシグニがアタックしたとき、対戦相手のパワー1000以下のシグニ１体を対象とし、あなたのデッキの一番上を公開する。そのカードがレベル４のシグニの場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 (aux.RefLevel で 4 として扱える)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ANY_LEVEL)
  e1:SetRange(LOCATION_MDECK+LOCATION_HAND+LOCATION_TRASH)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(aux.BanishPowerTarget(1000))
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if x:IsSigni() and aux.RefLevel(tp,x)==4 and tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
