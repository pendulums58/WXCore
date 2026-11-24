-- WDK04-011 超罠　ダークアリス
-- 【起】《ターン１回》《黒》：あなたのデッキの一番上を公開する。その後、そのカードがレベルが偶数のシグニの場合、そのカードを手札に加える。レベルが奇数のシグニの場合、そのカードをトラッシュに置き、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－8000する。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－10000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetEnaCost("{B}")
  -- 시그니가 아니면 뒷면으로 덱 위에(FAQ 1)
  e1:SetOperation(function(e,tp)
    local top=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not top then return end
    Duel.RevealCards(top)
    if not top:IsSigni() then return end
    if aux.RefLevel(tp,top)%2==0 then
      Duel.SendToHand(top)
      return
    end
    Duel.SendToTrash(top,REASON_EFFECT)
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then aux.AddPower(e,tc,-8000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-10000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e2)
end
