-- WD22-001-U 紅蓮の閻魔　ウリス
-- 【出】《黒》：あなたのトラッシュからシグニ１枚を対象とし、それを手札に加える。
-- 【起】手札から黒のシグニを２枚捨てる：対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- 【起】《ターン１回》エクシード2（あなたのルリグの下からカードを合計２枚ルリグトラッシュに置く）：あなたの黒のシグニ１体を場からトラッシュに置く。そうした場合、あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{B}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)  -- 코스트로 놓인 시그니도(FAQ 1)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCost(aux.DiscardCost(2,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1)
  e3:SetExceedCost(2)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()>0 and Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT)>0 then
      Duel.SendToLife(Duel.GetDecktopGroup(tp,1))
    end
  end)
  c:RegisterEffect(e3)
end
