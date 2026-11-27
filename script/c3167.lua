-- WX20-081 幻蟲　タランチュラ
-- 【常】：あなたのレゾナは対戦相手の効果によってバニッシュされない。
-- 【自】：このシグニがアタックしたとき、【チャーム】が付いている対戦相手のシグニ１体を対象とし、あなたの場にカード名に《アラクネ・パイダ》を含むシグニがある場合、ターン終了時まで、それのパワーを－7000する。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_BANISH_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsType(TYPE_RESONA) end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetCharm()~=nil end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"アラクネ・パイダ") end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then aux.AddPower(e,tc,-7000) end end
  end)
  c:RegisterEffect(e2)
end
