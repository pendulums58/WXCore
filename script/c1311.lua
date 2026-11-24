-- WD20-011 具英の角度　＃サンジョウ＃
-- 【常】英知=７：このシグニはバニッシュされない。
-- 【常】英知=１０：このシグニのパワーは＋2000され、このシグニは【ランサー】を得る。
-- （【ランサー】を持つシグニがバトルでシグニをバニッシュしたとき、対戦相手のライフクロスを１枚クラッシュする）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CANNOT_BANISH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(aux.EichiCon(7))
  c:RegisterEffect(e1)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(aux.EichiCon(10))
  e2:SetValue(2000)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetDescription(aux.Ability(id,1))
  e3:SetCode(EFFECT_LANCER)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCondition(aux.EichiCon(10))
  c:RegisterEffect(e3)
end
