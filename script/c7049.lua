-- WXK10-075 コードイート　ラムネ
-- 【常】：このシグニは【アクセ】が付いているかぎり、「【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをこのシグニのパワーと同じだけ－（マイナス）する。」を得る。
-- 【常】：これにアクセされているシグニは「【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、《青》を支払ってもよい。そうした場合、ターン終了時まで、それのパワーをこのシグニのパワーと同じだけ－（マイナス）する。」を得る。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Stringid(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetOperation(function(e,tp) local x=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if x then aux.AddPower(e,x,-e:GetHandler():GetPower()) end end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local h=e:GetHandler() return Duel.GetMatchingGroup(function(x) return x:GetAcceHost()==h end,h:GetControler(),LOCATION_ACCE,0,nil):GetCount()>0 end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  -- 【常】「これにアクセされているシグニは…を得る」는 아직
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
