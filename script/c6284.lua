-- WXK01-107 中罠　ピアノセン
-- 【出】：あなたのデッキの一番上のカードをトラッシュに置く。その後、それがレベルが偶数のシグニの場合、《黒》を支払ってもよい。そうした場合、対戦相手のレベル２以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    if not (x:IsSigni() and x:GetLevel()%2==0 and Duel.CanPayEna(tp,"{B}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{B}"),REASON_COST)
    local tc=Duel.SelectTarget(tp,function(y) return y:IsSigni() and y:GetLevel()<=2 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
