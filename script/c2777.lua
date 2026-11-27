-- WX15-058 コードイート　テキソス
-- 【出】手札から＜調理＞のシグニを１枚捨てる：あなたのデッキの上からカードを２枚エナゾーンに置く。
-- 【起】《緑×0》：あなたのシグニ１体を対象とし、このカードをエナゾーンからそれの【アクセ】にする。
-- 【常】：これにアクセされている＜調理＞のシグニは「【自】：このシグニがアタックしたとき、あなたのデッキの一番上のカードをエナゾーンに置く。」を得る。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()>0 then Duel.SendToEna(g) end
  end)
  c:RegisterEffect(e1)
  aux.AddAcce(c,aux.Ability(id,1))
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetCode(EVENT_ATTACK)
  g:SetOperation(aux.EnaChargeOp(1))
  -- [の間] 【常】 이것이 붙은 ＜調理＞ 시그니가 얻는다
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_FIELD)
  e9:SetCode(EFFECT_GRANT)
  e9:SetRange(LOCATION_ACCE)
  e9:SetTargetRange(LOCATION_SZONE,0)
  e9:SetTarget(function(e,x) return x==e:GetHandler():GetAcceHost() and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end)(x) end)
  e9:SetLabelObject(g)
  c:RegisterEffect(e9)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e3)
end
