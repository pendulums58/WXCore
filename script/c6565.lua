-- WXK05-023 紅蓮の使い魔　アンゴルモア
-- 【自】：このシグニが血晶武装状態になったとき、シグニ１体を対象とし、それをバニッシュする。
-- 【自】《ターン１回》：あなたが赤のスペルを使用したとき、対戦相手のシグニ１体を対象とし、《赤》を支払ってもよい。そうした場合、それをバニッシュする。
-- 【出】《赤》：あなたのデッキの上からカードを５枚見る。その中から赤のスペル１枚を公開し手札に加え、残りをシャッフルしてデッキの一番下に置く。
-- ライフバースト：あなたのデッキの上からカードを５枚見る。その中から赤のシグニ１枚と赤のスペル１枚を公開し手札に加え、残りをシャッフルしてデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BLOOD_ARMED)
  e1:SetCondition(function(e,tp,eg) return eg:IsContains(e:GetHandler()) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_USE_CARD)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg,ep) local x=eg:GetFirst() return ep==tp and x:IsType(TYPE_SPELL) and x:IsColor(COLOR_RED) end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if not (Duel.CanPayEna(tp,"{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}"),REASON_COST)
    Duel.Banish(tc)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{R}")
  e3:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g:Filter(function(y) return y:IsType(TYPE_SPELL) and y:IsColor(COLOR_RED) end,nil),0,1)
    
    if x:GetCount()>0 then Duel.RevealCards(x) Duel.SendToHand(x) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g:Filter(function(y) return y:IsType(TYPE_SPELL) and y:IsColor(COLOR_RED) end,nil),0,1)
    local y=Duel.SelectCards(tp,g:Filter(function(z) return z:IsSigni() and z:IsColor(COLOR_RED) end,nil),0,1)
    for z in y:Iter() do x:AddCard(z) end
    if x:GetCount()>0 then Duel.RevealCards(x) Duel.SendToHand(x) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e9)
end
