-- WX15-038 コードオーダー　ステキ
-- 【常】：このシグニはアクセされているかぎり、【ランサー】を得る。
-- 【常】：このシグニが《コードイート　テキソス》にアクセされているかぎり、このシグニのパワーは＋3000され、このシグニは対戦相手のシグニの効果を受けない。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のパワー12000以上のシグニ１体を対象とし、それをバニッシュする。②【エナチャージ２】
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_LANCER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsAcce() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(s.teki)
  e2:SetValue(3000)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetDescription(aux.Ability(id,1))
  e3:SetCode(EFFECT_IMMUNE)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCondition(s.teki)
  e3:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsSigni() end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e4:SetOperation(function(e,tp)
    if e:GetLabel()==1 then Duel.EnaCharge(tp,2) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e4)
end
function s.teki(e)
  local h=e:GetHandler()
  for x in Duel.GetMatchingGroup(function(a) return a:GetAcceHost()==h end,h:GetControler(),LOCATION_ACCE,0,nil):Iter() do
    if x:IsCardName(2777) then return true end
  end
  return false
end
