-- WD21-011 羅星　≡テンドウ≡
-- 【自】：あなたのライフクロス１枚がクラッシュされたとき、対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- 【出】《赤》《赤》：あなたのライフクロスが０枚の場合、あなたのデッキの一番上のカードをライフクロスに加える。
-- 【起】《ターン１回》《アタックフェイズアイコン》《赤×0》：あなたのライフクロス１枚をクラッシュする。
-- ライフバースト：カードを１枚引く。このターンにあなたのライフクロスが２枚以上クラッシュされていた場合、あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  -- 1장마다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{R}{R}")
  e2:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()==0 then Duel.SendToLife(Duel.GetDecktopGroup(tp,1)) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetCountLimit(1)
  e3:SetOperation(function(e,tp) Duel.Crush(tp,1) end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    if Duel.GetCrushedCount(tp)>=2 then Duel.SendToLife(Duel.GetDecktopGroup(tp,1)) end
  end)
  c:RegisterEffect(e4)
end
