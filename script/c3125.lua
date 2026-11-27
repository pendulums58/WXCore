-- WX20-033 双演の趣向　*サブカルズ*
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、《白》《緑》を支払ってもよい。そうした場合、それを手札に戻す。
-- 【自】：このシグニがバニッシュされたとき、あなたのデッキの一番上のカードをエナゾーンに置く。
-- ライフバースト：あなたのデッキから白の＜美巧＞のシグニ１枚までと緑の＜美巧＞のシグニ１枚までを探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
    if Duel.CanPayEna(tp,"{W}{G}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}{G}"),REASON_COST)
      Duel.SendToHand(tc)
    end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local a=aux.Search(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end)(x) and x:IsColor(COLOR_WHITE) end,1)
    a:Merge(aux.Search(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end)(x) and x:IsColor(COLOR_GREEN) end,1))
    if a:GetCount()>0 then Duel.RevealCards(a) Duel.SendToHand(a) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
