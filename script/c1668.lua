-- WDK08-Y11 幻水　スピノー
-- 【常】：このシグニはパワーが20000以上であるかぎり、バニッシュされない。
-- 【出】：あなたの手札から＜水獣＞のシグニを好きな枚数公開する。この方法でシグニを４枚以上公開した場合、ターン終了時まで、このシグニは【ランサー】を得る。
--   ６枚以上公開した場合、代わりに【Ｓランサー】を得る。
-- ライフバースト：対戦相手のシグニ１体を対象とし、《緑》を支払ってもよい。そうした場合、それをエナゾーンに置く。
local s,id=GetID()
s.suiju=aux.ClassFilter(0,RACE_SUIJU)  -- ＜水獣＞のシグニ
function s.initial_effect(c)
  -- [の間] 【常】 파워가 20000 이상인 동안
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_CANNOT_BANISH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():GetPower()>=20000 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(s.op)
  c:RegisterEffect(e2)
  -- 바니시가 아니라 에나 존에 놓는다(「バニッシュされない」도. FAQ 1)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and Duel.CanPayEna(tp,"{G}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
    Duel.SendToEna(tc)
  end)
  c:RegisterEffect(e3)
end
function s.op(e,tp)
  local n=aux.RevealFromHand(tp,s.suiju):GetCount()  -- 好きな枚数
  local c=e:GetHandler()
  if n<4 or not c:IsLocation(LOCATION_SZONE) then return end
  -- [まで] ターン終了時まで
  aux.GrantKeyword(e,c,n>=6 and EFFECT_S_LANCER or EFFECT_LANCER)
end
