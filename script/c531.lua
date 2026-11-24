-- WD18-009 コードイート　ハンバ
-- 【常】：このシグニがアクセされているかぎり、このシグニのパワーは＋3000される。
-- 【自】：このシグニがバニッシュされたとき、あなたのトラッシュから《アクセアイコン》を持つシグニ１枚を対象とし、このシグニがアクセされていた場合、それをエナゾーンに置く。
-- ライフバースト：あなたのデッキから《アクセアイコン》を持つシグニ１枚を探してエナゾーンに置く。その後、それを対象のあなたのシグニ１体の【アクセ】にしてもよい。その後、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 アクセされている 동안
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsAcce() end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  -- 자신에게 붙어 있던 카드는 먼저 룰 처리로 트래시에 있으므로 대상이 된다(FAQ 4)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.acce,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and e:GetHandler():IsPreviousAcce() then Duel.SendToEna(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local x=aux.Search(tp,s.acce,1):GetFirst()
    if x then
      Duel.SendToEna(x)
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) and not tc:IsAcce() and x:IsLocation(LOCATION_ENA) and Duel.SelectYesNo(tp) then
        Duel.Acce(x,tc)
      end
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
function s.acce(c) return c:IsSigni() and c:HasAcceIcon() end
