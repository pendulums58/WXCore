-- WX15-073 勝利の円卓　アルスラ
-- 【ライズ】あなたのレベル１の赤のシグニ１体の上に置く
-- 【出】：対戦相手のパワー1000以下のシグニ１体を対象とし、それをバニッシュする。
-- 【出】：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddRise(c,function(x) return x:IsSigni() and x:IsColor(COLOR_RED) and x:GetLevel()==1 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(aux.BanishPowerTarget(1000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
