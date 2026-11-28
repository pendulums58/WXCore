-- WXK05-065 コードイート　ティラミス
-- 【自】《ターン１回》：このシグニに【アクセ】が付いたとき、それがレベル２以下の【アクセ】の場合、【エナチャージ１】をする。レベル３以上の【アクセ】の場合、カードを１枚引く。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ACCE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) return eg:GetFirst():GetAcceHost()==e:GetHandler() end)
  e1:SetOperation(function(e,tp,eg)
    if eg:GetFirst():GetLevel()<=2 then Duel.EnaCharge(tp,1) else Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e9)
end
