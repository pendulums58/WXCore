-- WX14-043 幻獣　トンビ
-- 【出】：あなたのデッキの一番上を公開する。それが＜空獣＞のシグニの場合、それを手札に加える。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,1)):GetFirst()
    if not x then return end
    Duel.RevealCards(x)
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU)) end)(x) then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
