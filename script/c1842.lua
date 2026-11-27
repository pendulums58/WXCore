-- WX01-029 羅輝石　アダマスフィア
-- 【自】：あなたの赤のシグニがアタックしたとき、ターン終了時まで、それのパワーを＋2000する。
-- 【出】《赤》：対戦相手のパワー7000以下のシグニ１体を対象とし、それをバニッシュする。
-- 【起】《赤》《赤》：ターン終了時まで、このシグニは【ダブルクラッシュ】を得る。
-- ライフバースト：対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- 자신도, 여러 체면 겹친다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:IsSigni() and x:GetControler()==tp and x:IsColor(COLOR_RED) end)
  e1:SetOperation(function(e,tp,eg)
    local x=eg:GetFirst()
    if x:IsLocation(LOCATION_SZONE) then aux.AddPower(e,x,2000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{R}")
  e2:SetTarget(aux.BanishPowerTarget(7000))
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetEnaCost("{R}{R}")
  e3:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_DOUBLE_CRUSH) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(aux.BanishPowerTarget(10000))
  e4:SetOperation(aux.BanishOp)
  c:RegisterEffect(e4)
end
