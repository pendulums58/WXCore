-- WXK04-048 コードイート　アイスケーキ
-- 【常】：このシグニは【アクセ】が付いているかぎり、「【自】：このシグニがアタックしたとき、《青》を支払ってもよい。そうした場合、対戦相手は手札を１枚捨てる。」を得る。
-- 【常】：これにアクセされているレベル３以上のシグニは「【自】：このシグニがアタックしたとき、対戦相手は手札を１枚捨てる。」を得る。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手は手札を１枚捨てる。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Stringid(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
    aux.Discard(1-tp,1)
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local h=e:GetHandler() return Duel.GetMatchingGroup(function(a) return a:GetAcceHost()==h end,h:GetControler(),LOCATION_ACCE,0,nil):GetCount()>0 end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local g2=Effect.CreateEffect(c)
  g2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g2:SetDescription(aux.Stringid(id,1))
  g2:SetCode(EVENT_ATTACK)
  g2:SetOperation(function(e,tp) aux.Discard(1-tp,1) end)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 이것이 붙은 시그니
  e3:SetDescription(aux.Ability(id,1))
  e3:SetCode(EFFECT_GRANT)
  e3:SetRange(LOCATION_ACCE)
  e3:SetTargetRange(LOCATION_SZONE,0)
  e3:SetTarget(function(e,x) return x==e:GetHandler():GetAcceHost() and x:GetLevel()>=3 end)
  e3:SetLabelObject(g2)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then aux.Discard(1-tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e9)
end
