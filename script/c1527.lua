-- WDK04-015 中罠　マッドハッター
-- 【出】：あなたのデッキの一番上を公開する。それをデッキの一番下に置いてもよい。この方法で公開したカードがレベルが奇数のシグニの場合、《黒》を支払ってもよい。そうした場合、ターン終了時まで、このシグニのパワーは＋7000され、このシグニは「【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－2000する。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  -- 무엇이 나와도 아래에 놓을 수 있고, 위에 두어도 《黒》을 낼 수 있다(FAQ 1·2)
  e1:SetOperation(function(e,tp)
    local h,top=e:GetHandler(),Duel.GetDecktopGroup(tp,1):GetFirst()
    if not top then return end
    Duel.RevealCards(top)
    if Duel.SelectYesNo(tp) then Duel.SendToDeckBottom(top,false) end
    if not top:IsSigni() or aux.RefLevel(tp,top)%2==0 then return end
    if not (Duel.CanPayEna(tp,"{B}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{B}"),REASON_COST)
    if not h:IsLocation(LOCATION_SZONE) then return end
    -- [まで] ターン終了時まで
    aux.AddPower(e,h,7000)
    local e1=Effect.CreateEffect(h)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetDescription(aux.Ability(id,0))
    e1:SetCode(EVENT_ATTACK)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    end)
    e1:SetOperation(function(e,tp)
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-2000) end
    end)
    h:GrantEffect(e1)
  end)
  c:RegisterEffect(e1)
end
