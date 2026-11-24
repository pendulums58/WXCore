-- WDK07-Y14 羅植　アベリア
-- 【常】：このシグニは中央のシグニゾーンにあるかぎり、「【自】：このシグニがアタックしたとき、あなたの場に＜植物＞のシグニが３体ある場合、【エナチャージ２】をする。」を得る。
-- 【自】：このシグニが開花したとき、カードを１枚引く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
s.shoku=aux.ClassFilter(0,RACE_SHOKUBUTSU)  -- ＜植物＞のシグニ
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(s.shoku,tp,LOCATION_SZONE,0,nil):GetCount()==3 then Duel.EnaCharge(tp,2) end
  end)
  -- [の間] 【常】 중앙 시그니 존에 있는 동안
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SIGNI,0)
  e1:SetTarget(function(e,x) return x==e:GetHandler() and x:IsInZone("signi_center") end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BLOOM)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
end
