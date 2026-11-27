-- WX09-045 三炎の宝石
-- 対戦相手のパワー8000以下のシグニ１体を対象とし、それをバニッシュする。あなたの場に赤のシグニが３体あり、それらが共通するクラスを持つ場合、代わりに対戦相手のパワー15000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local n=(function() local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_RED) end,tp,LOCATION_SZONE,0,nil) return g:GetCount()==3 and aux.ShareClass(g) end)() and 15000 or 8000
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=n end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
end
