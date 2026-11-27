-- WX08-010 不灯不屈
-- あなたのライフクロス２枚をクラッシュする。その後、この方法でクラッシュしたライフクロス１枚につき対戦相手のシグニ１体を対象とし、それらをバニッシュする。この方法でクラッシュされたカードのライフバーストは発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local n=Duel.Crush(tp,2,false,true):GetCount()
    if n==0 then return end
    local g=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,n,n,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
end
