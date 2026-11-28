-- WXK03-020 師の遊姫　プリキャス
-- 【自】《ターン１回》：このシグニがアタックしたとき、あなたのアップ状態のシグニ１体を場から手札に戻してもよい。そうした場合、手札からレベル３以下の＜遊具＞のシグニ１枚を場に出す。
-- 【出】：このシグニが効果によって場に出た場合、《白》《白》《無》《無》を支払ってもよい。そうした場合、あなたのすべての＜遊具＞のシグニをアップする。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCountLimit(1)
  e1:SetOperation(function(e,tp,eg)
    -- 돌려보낸 것도 낼 수 있다(FAQ 1)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsUp() end,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()==0 or not Duel.SelectYesNo(tp) or Duel.SendToHand(Duel.SelectCards(tp,g,1,1))==0 then return end
    local h=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_YUGU) end)(x) and x:GetLevel()<=3 end,tp,LOCATION_HAND,0,nil)
    if h:GetCount()>0 then Duel.PutOnField(Duel.SelectCards(tp,h,1,1):GetFirst(),tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCondition(function(e,tp,eg,ep,ev,re) return re~=nil end)
  e2:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{W}{W}{C}{C}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}{W}{C}{C}"),REASON_COST)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_YUGU) end,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()>0 then Duel.Up(g) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      -- [まで] ターン終了時まで
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_CANNOT_ATTACK)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
    end
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
