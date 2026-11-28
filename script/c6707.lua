-- WXK07-004 真・遊月・鍵
-- 【出】《コインアイコン》：対戦相手のすべてのシグニをバニッシュする。
-- 【出】《コインアイコン》：カードを２枚引き、【エナチャージ２】をする。
-- 【起】《ターン１回》《赤》《緑》：あなたのシグニ１体を対象とし、ターン終了時まで、それは【アサシン】を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCoinCost(1)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCoinCost(1)
  e2:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,2)
    Duel.EnaCharge(tp,2)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_KEY)
  e3:SetCountLimit(1)
  e3:SetEnaCost("{R}{G}")
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.GrantKeyword(e,tc,EFFECT_ASSASSIN)
    end
  end)
  c:RegisterEffect(e3)
end
