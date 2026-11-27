-- WX05-009 一燭即発
-- あなたのアップ状態の＜龍獣＞のシグニ１体を対象とし、それをダウンする。その後、パワーが、この方法でダウンしたシグニのパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end)(x) and x:IsUp() end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and tc:IsUp()) then return end
    Duel.Down(tc)
    local p=tc:GetPower()
    local x=Duel.SelectTarget(tp,function(c) return c:IsSigni() and c:GetPower()<=p end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if x then Duel.Banish(x) end
  end)
  c:RegisterEffect(e1)
end
