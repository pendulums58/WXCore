-- WD13-012 原槍　エナジェ
-- 【常】：あなたのエナゾーンにあるカードは【マルチエナ】を持つ。
-- 【出】《白》：あなたのシグニ１体を対象とし、それをアップする。
-- 【起】《白》《白》：このターン、対戦相手のシグニがバニッシュされる場合、エナゾーンに置かれる代わりにトラッシュに置かれる。
-- ライフバースト：あなたのデッキから白のカードを１枚探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_MULTI_ENA)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_ENA,0)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{W}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Up(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetEnaCost("{W}{W}")
  e3:SetOperation(function(e,tp)
    -- [の間] 「このターン」. 이 시그니가 장을 떠나도 이어진다(FAQ)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_BANISH_TO_TRASH)
    e1:SetTargetRange(0,LOCATION_SZONE)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp) aux.SearchToHand(tp,function(x) return x:IsColor(COLOR_WHITE) end,1) end)
  c:RegisterEffect(e4)
end
