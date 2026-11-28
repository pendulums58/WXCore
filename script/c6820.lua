-- WXK08-034 コードＶＬ　赤羽葉子
-- 【常】：あなたの登録者数が８０万人を達成しているかぎり、このシグニは「【自】《ターン１回》：このシグニがアタックしたとき、あなたのすべてのシグニがダウン状態の場合、《白》を支払ってもよい。そうした場合、このシグニをアップする。」を得る。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Stringid(id,2))
  g:SetCode(EVENT_ATTACK)
  g:SetCountLimit(1)
  g:SetCondition(function(e,tp) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and not x:IsDown() end,tp,LOCATION_SZONE,0,nil):GetCount()==0 end)
  g:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{W}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}"),REASON_COST)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetSubscribers(e:GetHandlerPlayer())>=80 end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e9)
end
