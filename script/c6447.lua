-- WXK03-073 幻怪　モモイヌ
-- 【自】《ターン１回》：場にあるこのシグニが他のシグニゾーンに移動したとき、ターン終了時まで、このシグニのパワーを＋2000し、このシグニは【ランサー】を得る。
-- （【ランサー】を持つシグニがバトルでシグニをバニッシュしたとき、対戦相手のライフクロスを１枚クラッシュする）
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_SIGNI_MOVED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) return eg:IsContains(e:GetHandler()) end)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    aux.AddPower(e,h,2000)
    aux.GrantKeyword(e,h,EFFECT_LANCER)
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
