-- WX17-041 超罠　タイマーボム
-- 【起】《ダウン》：あなたのデッキの上からカードを３枚見る。その中から１枚を【トラップ】としてあなたのシグニゾーンに設置してもよい。残りを好きな順番でデッキの一番下に置く。
-- 【トラップアイコン】：《青》《青》《青》《無》《無》《無》を支払ってもよい。そうした場合、対戦相手のすべてのシグニを手札に戻す。
-- ライフバースト：対戦相手のシグニ１体を対象とし、あなたの【トラップ】１つを手札に戻す。そうした場合、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g,0,1):GetFirst()
    if x then Duel.SetTrap(x,tp) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_TRAP)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetOperation(function(e,tp)
    if Duel.CanPayEna(tp,"{U}{U}{U}{C}{C}{C}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}{U}{U}{C}{C}{C}"),REASON_COST)
      local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
      if g:GetCount()>0 then Duel.SendToHand(g) end
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local t=Duel.GetMatchingGroup(nil,tp,LOCATION_TRAP,0,nil)
    if t:GetCount()==0 or Duel.SendToHand(Duel.SelectCards(tp,t,1,1))==0 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
end
