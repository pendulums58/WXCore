-- WXK07-074 羅菌　ビタミンC
-- 【自】《ターン１回》：【チャーム】が付いているあなたのシグニ１体がバニッシュされたとき、カードを１枚引くか【エナチャージ１】をする。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) for x in eg:Iter() do if x:GetOwner()==tp and x:IsPreviousCharm() then return true end end return false end)
  e1:SetOperation(function(e,tp,eg)
    if Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
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
