-- WX11-053 コードメイズ　サピドゥ
-- 【常】：対戦相手の場に能力を持たないシグニがあるかぎり、このシグニの基本パワーは12000になり、このシグニは「【自】：このシグニがアタックしたとき、対戦相手のパワー3000以下のシグニ１体を対象とし、それを手札に戻す。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetTarget(aux.BanishPowerTarget(3000))
  g:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  -- [の間] 【常】
  aux.BasePower(c,12000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and not x:HasAbility() end,e:GetHandlerPlayer(),0,LOCATION_SZONE,nil):GetCount()>0 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SIGNI,0)
  e1:SetTarget(function(e,x) return x==e:GetHandler() and (function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and not x:HasAbility() end,e:GetHandlerPlayer(),0,LOCATION_SZONE,nil):GetCount()>0 end)(e) end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
end
