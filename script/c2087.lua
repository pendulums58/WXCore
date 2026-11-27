-- WX05-024 幻獣神　ライアン
-- 【常】：対戦相手の効果によって、シグニのパワーは増減しない。
-- 【常】：あなたのパワー15000以上のシグニは、対戦相手の、スペルとシグニの効果を受けない。
-- ライフバースト：対戦相手のパワー10000以上のシグニ１体を対象とし、あなたのデッキの一番上のカードをエナゾーンに置き、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 상대의 효과로는 모든 시그니의 파워가 바뀌지 않는다(값 설정은 그대로. FAQ 1~4)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_NO_OPP_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(1,0)
  c:RegisterEffect(e1)
  -- [の間] 【常】 ライフバースト도(FAQ 5)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_IMMUNE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return x:IsSigni() and x:GetPower()>=15000 end)
  e2:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and (sc:IsSigni() or sc:IsType(TYPE_SPELL)) end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=10000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,1)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
end
