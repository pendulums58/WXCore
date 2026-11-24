-- WD20-001 ママ♥４
-- 【出】《コインアイコン》《コインアイコン》《コインアイコン》：あなたのデッキの一番上のカードをライフクロスに加える。
-- 【自】：あなたのターンの間、あなたのライフクロスにカード１枚が加えられたとき、対戦相手のシグニ１体を対象とし、《緑》を支払ってもよい。そうした場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCoinCost(3)
  e1:SetOperation(function(e,tp) Duel.SendToLife(Duel.GetDecktopGroup(tp,1)) end)
  c:RegisterEffect(e1)
  -- 1장마다 트리거한다. 한 번에 《緑》 1번만(FAQ 2)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_LIFE_ADDED)
  e2:SetRange(LOCATION_LRIG)
  e2:SetCondition(function(e,tp,eg,ep) return ep==tp and Duel.GetTurnPlayer()==tp end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and Duel.CanPayEna(tp,"{G}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
    if tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
