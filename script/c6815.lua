-- WXK08-028 炎魔の巨人　スルト
-- 【自】《ターン１回》：あなたのライフクロスが他の領域に移動したとき、対戦相手のシグニ１体を対象とし、《赤》を支払ってもよい。そうした場合、それをバニッシュする。
-- 【出】《無》：あなたのライフクロスをすべて手札に加え、この方法で手札に加えたカードの枚数まで、手札からカードをライフクロスに加える。このゲームの間、あなたのライフバーストは発動しない。
-- ライフバースト：カードを１枚引く。あなたのライフクロスが４枚以下の場合、追加で【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 「ライフクロスが他の領域に移動したとき」(근사: 크러시되었을 때)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if not (Duel.CanPayEna(tp,"{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}"),REASON_COST)
    Duel.Banish(tc)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{C}")
  e2:SetOperation(function(e,tp,eg)
    local life=Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil)
    local n=life:GetCount()>0 and Duel.SendToHand(life) or 0
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if n>0 and h:GetCount()>0 then Duel.SendToLife(Duel.SelectCards(tp,h,0,math.min(n,h:GetCount()))) end
    -- [の間] このゲームの間
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DISABLE_ABILITY)
    e1:SetTargetRange(LOCATION_CHECK+LOCATION_LIFE,0)
    e1:SetValue(ABILITY_LIFEBURST)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=4 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e9)
end
