-- WX03-032 羅植　カーノ
-- 【自】：あなたのターンの間、あなたのエナゾーンにカード１枚が置かれたとき、ターン終了時まで、このシグニのパワーを＋3000する。
-- 【自】：このシグニのパワーが15000以上になったとき、対戦相手のシグニ１体を対象とし、このシグニとそれをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_ENA)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) return Duel.GetTurnPlayer()==tp and eg:GetFirst():GetOwner()==tp end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,3000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetCode(EFFECT_POWER_WATCH)
  e2:SetRange(LOCATION_SZONE)
  e2:SetValue(15000)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,1))
  e3:SetCode(EVENT_POWER_REACHED)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local g=Group.CreateGroup()
    local h,tc=e:GetHandler(),Duel.GetFirstTarget()
    if h:IsLocation(LOCATION_SZONE) then g:AddCard(h) end
    if tc and tc:IsRelateToEffect(e) then g:AddCard(tc) end
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e3)
end
