-- WXK02-035 浴英の発見　アルキメス
-- 【自】：このシグニがアタックしたとき、対戦相手の凍結状態のシグニ１体を対象とし、《青》を支払ってもよい。そうした場合、それをバニッシュする。
-- 【出】《青》：あなたのデッキの一番下のカードをチェックゾーンに置く。それがシグニの場合、それを場に出してもよい。場に出さない場合、それをトラッシュに置く。
-- ライフバースト：対戦相手のシグニを２体まで対象とし、それらをダウンし凍結する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsFrozen() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if not (Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
    Duel.Banish(tc)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{U}")
  e2:SetOperation(function(e,tp,eg)
    -- 체크 존을 거친다: 「デッキからトラッシュ」가 아니다(FAQ 7)
    local x=Duel.GetDeckbottomGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(x)
    if x:IsSigni() and Duel.SelectYesNo(tp) and Duel.PutOnField(x,tp) then return end
    Duel.SendToTrash(x,REASON_EFFECT)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    for x in Duel.GetTargets():Iter() do
      if x:IsRelateToEffect(e) then Duel.Down(x) Duel.Freeze(x) end
    end
  end)
  c:RegisterEffect(e9)
end
