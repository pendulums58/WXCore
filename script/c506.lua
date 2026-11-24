-- WD17-001 決死の記憶　リル
-- 【出】《コインアイコン》：対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
-- 【起】《ターン１回》《赤》《赤》《赤》：《ライズアイコン》を持つあなたのシグニ１体を対象とし、ターン終了時まで、それは「【自】：このシグニが正面にあるシグニ１体をバニッシュしたとき、このシグニをアップする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCoinCost(1)
  e1:SetTarget(aux.BanishPowerTarget(12000))
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and s.filter(tc) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetEnaCost("{R}{R}{R}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    -- [まで] ターン終了時まで
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetDescription(aux.Ability(id,1))
    e1:SetCode(EVENT_BANISHED)
    e1:SetRange(LOCATION_SZONE)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetCondition(function(e,tp,eg)
      local h=e:GetHandler()
      local z=h:GetZone()
      return Duel.GetBanisher()==h and z~=nil and Duel.GetFrontZone(z)==eg:GetFirst():GetPreviousZone()
    end)
    e1:SetOperation(function(e,tp) Duel.Up(e:GetHandler()) end)
    tc:GrantEffect(e1)
  end)
  c:RegisterEffect(e2)
end
function s.filter(c) return c:IsSigni() and c:GetPower()<=12000 end
