-- WX20-074 堕落の才娘　ルチーフェロ
-- 【出】：他のシグニ１体を対象とし、ターン終了時まで、それの基本パワーを10000にする。
-- 【出】：対戦相手のシグニ１体を対象とし、あなたの場かトラッシュにカード名に《ルシファル》を含むシグニがある場合、ターン終了時まで、それのパワーを－7000する。この効果によってそれのパワーが０以下になった場合、あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_BASE_POWER)
        e1:SetValue(10000)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if not (Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"ルシファル") end,tp,LOCATION_SZONE,0,nil):GetCount()>0 or Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"ルシファル") end,tp,LOCATION_TRASH,0,nil):GetCount()>0) then return end
    aux.AddPower(e,tc,-7000)  -- [まで]
    if tc:GetPower()<=0 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e2)
end
