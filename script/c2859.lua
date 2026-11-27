-- WX16-041 大罠　アリババ
-- 【出】手札から《トラップアイコン》を持つカードを１枚捨てる：あなたのデッキから＜トリック＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- 《トラップアイコン》：対戦相手のパワー15000以上のシグニ１体を対象とし、それをデッキの一番上に置く。
-- ライフバースト：あなたのデッキから《トラップアイコン》を持つカード１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,Card.HasTrapIcon))
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_TRICK)) end,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_TRAP)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=15000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckPosition(tc,1) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    aux.SearchToHand(tp,Card.HasTrapIcon,1)
  end)
  c:RegisterEffect(e3)
end
