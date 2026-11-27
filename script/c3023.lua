-- WX18-073 楽英の混在　＃アキハバ＃
-- 【出】英知＝５：あなたのデッキの一番上を公開する。それが＜英知＞のシグニの場合、それを手札に加える。
-- 【自】英知＝８：このシグニがアタックしたとき、あなたのデッキの一番上を公開する。それが＜英知＞のシグニの場合、それを手札に加え、あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(aux.EichiCon(5))
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(Group.CreateGroup(x))
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end)(x) then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetCondition(aux.EichiCon(8))
  e2:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(Group.CreateGroup(x))
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end)(x) then Duel.SendToHand(x) Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e2)
end
