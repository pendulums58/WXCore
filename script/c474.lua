-- SP07-011 不思議な童話　メルへ（「selector spread WIXOSS」 BOX2 初回限定特典）
-- 【常】：あなたが《白》を支払う際、代わりにあなたのエナゾーンから＜美巧＞のシグニ１枚をトラッシュに置いてもよい。
-- 【出】《緑》：あなたの＜美巧＞のシグニ１体をバニッシュする。そうした場合、この方法でバニッシュしたシグニよりレベルが１つ大きいシグニ１枚をあなたのデッキから探して場に出し、デッキをシャッフルする。
-- 【起】《緑》《白》：対戦相手のパワー15000以上のシグニ１体を対象とし、それを手札に戻す。
-- ライフバースト：【エナチャージ２】
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 《白》 1개마다 1장(FAQ 1·2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCode(EFFECT_ADD_PAY_COLOR)
  e1:SetTargetRange(LOCATION_ENA,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsClass(0,RACE_BIKOU) end)
  e1:SetValue(COLOR_WHITE)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{G}")
  -- 다른 시그니 존에 내도 된다(FAQ 3)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_BIKOU) end,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()==0 then return end
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    local lv=x:GetLevel()
    if Duel.Banish(x)==0 then return end
    local y=aux.Search(tp,function(z) return z:IsSigni() and z:GetLevel()==lv+1 end,1):GetFirst()
    if y then Duel.PutOnField(y,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetEnaCost("{G}{W}")
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=15000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:GetPower()>=15000 then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(aux.EnaChargeOp(2))
  c:RegisterEffect(e4)
end
