-- WX17-063 中罠　プラスボム
-- 【出】《青×0》：あなたのトラッシュから《中罠　プラスボム》以外の《トラップアイコン》を持つシグニを３枚まで対象とし、それらをデッキに加えてシャッフルする。
-- 【トラップアイコン】：対戦相手は自身のトラッシュからすべてのカードをデッキに加えてシャッフルする。その後、この方法で１０枚以上のカードがデッキに加えられた場合、あなたは《青》を支払ってもよい。そうした場合、対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasTrapIcon() and not x:IsCardName(id) end,tp,LOCATION_TRASH,0,0,3,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToDeckShuffle(g,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_TRAP)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_TRASH,0,nil)
    local n=g:GetCount()
    Duel.SendToDeckShuffle(g,1-tp)
    if n<10 then return end
    if Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
end
