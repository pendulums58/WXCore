-- WXK02-055 箱英の発射　クウキホウ
-- 【自】：このシグニがアタックしたとき、《青》を支払ってもよい。そうした場合、あなたのデッキの一番下のカードをトラッシュに置く。その後、そのカードがレベル２のシグニの場合、対戦相手のレベル２以下のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
    local x=Duel.GetDeckbottomGroup(tp,1):GetFirst()
    if not x then return end
    Duel.SendToTrash(x,REASON_EFFECT)
    if not (x:IsSigni() and x:GetLevel()==2) then return end
    local tc=Duel.SelectTarget(tp,function(y) return y:IsSigni() and y:GetLevel()<=2 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
