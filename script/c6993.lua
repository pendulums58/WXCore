-- WXK10-019 アロス＆コードピルルク　ＫＥＹ
-- 【出】：あなたのデッキからカード１枚を探してエナゾーンに置き、デッキをシャッフルする。
-- 【起】手札を１枚捨てる：次のターンの間、あなたは対戦相手のルリグによってダメージを受けない。
-- 【起】このキーを場からルリグトラッシュに置く：対戦相手のシグニ１体を対象とし、それをエナゾーンに置く。このターンと次のターンの間、対戦相手はこの方法でエナゾーンに置いたシグニと同じ名前のシグニを新たに場に出せない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local x=aux.Search(tp,nil,1):GetFirst()
    if x then Duel.SendToEna(x) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  -- 「次のターンの間」(근사: 다음 내 턴 개시까지)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetCost(aux.DiscardCost(1))
  e2:SetOperation(function(e,tp,eg)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_PREVENT_DAMAGE)
    e1:SetTargetRange(1,0)
    e1:SetValue(2)
    e1:SetReset(RESET_MY_TURN)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  -- 「同じ名前のシグニを新たに場に出せない」는 아직
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_KEY)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToEna(tc)
    end
  end)
  c:RegisterEffect(e3)
end
