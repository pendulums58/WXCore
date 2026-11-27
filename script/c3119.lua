-- WX20-025 羅星　≡エラキス≡
-- 【常】：あなたの他のシグニは対戦相手の効果によってダウンしない。
-- 【自】：あなたのメインフェイズの間、対戦相手の中央のシグニゾーンにあるシグニがバニッシュされたとき、あなたのデッキの一番上のカードをエナゾーンに置く。
-- 【出】：対戦相手の中央のシグニゾーンにあるパワー12000以下のシグニ１体を対象とし、あなたのトラッシュにカード名に《ガーネットスター》を含むカードがある場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_NO_DOWN_BY_OPP)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x~=e:GetHandler() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return Duel.GetTurnPlayer()==tp and Duel.GetPhase()==PHASE_MAIN and x:GetOwner()~=tp and x:GetPreviousZone()==Duel.GetSigniZones(1-tp)[2] end)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsInZone("signi_center") and x:GetPower()<=12000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"ガーネットスター") end,tp,LOCATION_TRASH,0,nil):GetCount()>0 then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e3)
end
