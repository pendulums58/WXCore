-- WDK08-Y14 幻水　メガネワニ
-- 【自】：このシグニがアタックしたとき、あなたのエナゾーンから＜水獣＞のシグニを１枚まで対象とし、手札から＜水獣＞のシグニを２枚公開してもよい。
--   そうした場合、それを手札に加える。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
s.suiju=aux.ClassFilter(0,RACE_SUIJU)  -- ＜水獣＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.suiju,tp,LOCATION_ENA,0,0,1,nil)
  end)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
-- 대상이 없어도 공개할 수 있다. 그 경우 그 뒤는 아무것도 하지 않는다(FAQ 1)
function s.op(e,tp)
  if aux.RevealFromHand(tp,s.suiju,2):GetCount()~=2 then return end
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
end
