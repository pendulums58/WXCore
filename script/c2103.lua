-- WX05-042 増武
-- このターン、あなたのメインフェイズの間、あなたの＜植物＞のシグニ１体がダウン状態になったとき、それがこのターンで３回目である場合、対象の対戦相手のシグニ１体をバニッシュし、あなたのエナゾーンから対象のカードを１枚手札に加え、カードを１枚引く。このカードの効果は１ターンに一度しか発動しない。
-- ライフバースト：あなたのデッキの一番上のカードをエナゾーンに置く。その後、あなたのエナゾーンにあるカードが４枚以下の場合、追加であなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン」 이 카드의 효과는 턴 1회. 쓰기 전의 다운도 센다(FAQ 2·3)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCode(EVENT_DOWN)
    e1:SetCountLimit(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetCondition(function(e,tp,eg)
      if Duel.GetTurnPlayer()~=tp or Duel.GetPhase()~=PHASE_MAIN then return false end
      local x=eg:GetFirst()
      if not ((function(x) return x:IsSigni() and (x:IsClass(0,RACE_SHOKUBUTSU)) end)(x) and x:GetControler()==tp) then return false end
      local n=0
      for _,c in ipairs(Duel.GetDownLog(tp)) do if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_SHOKUBUTSU)) end)(c) then n=n+1 end end
      return n==3
    end)
    e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
      Duel.SelectTarget(tp,nil,tp,LOCATION_ENA,0,1,1,nil)
    end)
    e1:SetOperation(function(e,tp)
      for tc in Duel.GetTargets():Iter() do
        if tc:IsRelateToEffect(e) then
          if tc:IsLocation(LOCATION_ENA) then Duel.SendToHand(tc) else Duel.Banish(tc) end
        end
      end
      Duel.Draw(tp,1)
    end)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,1)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_ENA,0,nil):GetCount()<=4 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e2)
end
