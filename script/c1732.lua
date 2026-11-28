-- WDK12-015 羅菌 カーボ
-- 【常】：このシグニに【チャーム】が付いているかぎり、このシグニのパワーは＋2000される。
-- 【自】《ターン１回》：このシグニがアタックしたとき、《緑》を支払い、あなたの場にある【チャーム】１枚をトラッシュに置いてもよい。そうした場合、このシグニをアップする。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():GetCharm()~=nil end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetCountLimit(1)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local g=Group.CreateGroup()
    for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetCharm()~=nil end,tp,LOCATION_SZONE,0,nil):Iter() do g:AddCard(x:GetCharm()) end
    if g:GetCount()==0 or not Duel.CanPayEna(tp,"{G}") or not Duel.SelectYesNo(tp) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)
    if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e3)
end
