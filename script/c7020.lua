-- WXK10-046 幻怪電　ライジュウ
-- 【自】：あなたがアーツを使用したとき、シグニ１体を対象とし、ターン終了時まで、それのパワーを＋2000する。
-- 【自】：このシグニがアタックしたとき、このシグニのパワーが7000以上の場合、カードを１枚引く。
-- 【自】：このシグニがアタックしたとき、対戦相手のレベル３以下のシグニ１体を対象とし、このシグニのパワーが15000以上の場合、それをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_USE_CARD)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp and eg:GetFirst():IsType(TYPE_ARTS) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,2000)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp,eg)
    if e:GetHandler():GetPower()>=7000 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ATTACK)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if e:GetHandler():GetPower()>=15000 then Duel.SendToEna(tc) end
    end
  end)
  c:RegisterEffect(e3)
end
