-- WX16-043 虚英の数字　＃キョスウ＃
-- 【起】《ダウン》：あなたのデッキの上からカードを２枚見る。その中から＜英知＞のシグニ１枚を公開し手札に加え、残りを好きな順番でデッキの一番下に置く。
-- 【起】英知=11《ダウン》：あなたのデッキの上からカードを２枚見る。その中から１枚を手札に加え、残りをデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end,nil),0,1)
    if x:GetCount()>0 then Duel.RevealCards(x) Duel.SendToHand(x) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(aux.SelfDownCost)
  e2:SetCondition(aux.EichiCon(11))
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    Duel.SendToHand(Duel.SelectCards(tp,g,1,1))
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,false) end
  end)
  c:RegisterEffect(e2)
end
