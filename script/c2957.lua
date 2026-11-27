-- WX17-076 コードイート　ツナマヨ
-- 【起】《緑×0》：あなたのシグニ１体を対象とし、このカードをエナゾーンからそれの【アクセ】にする。
-- 【自】：このカードが【アクセ】としてレベル２以下の＜調理＞のシグニに付いたとき、カードを１枚引く。
-- 【自】：このカードが【アクセ】としてレベル３以上の＜調理＞のシグニに付いたとき、あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddAcce(c,aux.Ability(id,0))
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ACCE)
  e2:SetRange(LOCATION_ACCE)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x==e:GetHandler():GetAcceHost() and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end)(x) and x:GetLevel()<=2 end)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ACCE)
  e3:SetRange(LOCATION_ACCE)
  e3:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x==e:GetHandler():GetAcceHost() and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end)(x) and x:GetLevel()>=3 end)
  e3:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,1)
  end)
  c:RegisterEffect(e3)
end
