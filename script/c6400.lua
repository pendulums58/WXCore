-- WXK03-026 幻怪姫　ネムリヒメ
-- 【常】：対戦相手の効果によって、このシグニのパワーは－（マイナス）されない。
-- 【常】：このシグニはパワーが20000以上であるかぎり、【Ｓランサー】を得る。
-- 【常】：このターンにあなたがアーツを３回以上使用していた場合、このシグニはバニッシュされない。
-- 【自】《ターン１回》：場にあるこのシグニが他のシグニゾーンに移動したとき、あなたのルリグデッキに《刺々迷路》１枚を加える。
-- ライフバースト：あなたのルリグデッキに《刺々迷路》２枚を加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_NO_OPP_POWER_CARD)
  e1:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_S_LANCER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) return e:GetHandler():GetPower()>=20000 end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EFFECT_CANNOT_BANISH)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCondition(function(e) return Duel.GetArtsUsedCount(e:GetHandlerPlayer())>=3 end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e4:SetDescription(aux.Ability(id,3))
  e4:SetCode(EVENT_SIGNI_MOVED)
  e4:SetRange(LOCATION_SZONE)
  e4:SetCountLimit(1)
  e4:SetCondition(function(e,tp,eg) return eg:IsContains(e:GetHandler()) end)
  e4:SetOperation(function(e,tp,eg)
    Duel.AddCraft(6288,tp)
  end)
  c:RegisterEffect(e4)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.AddCraft(6288,tp)
    Duel.AddCraft(6288,tp)
  end)
  c:RegisterEffect(e9)
end
