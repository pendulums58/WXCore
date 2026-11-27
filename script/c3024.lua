-- WX18-074 育英の改進　＃オオクマ＃
-- 【自】：このシグニがバニッシュされたとき、《緑》を支払ってもよい。そうした場合、あなたのデッキからレベル２の＜英知＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetOperation(function(e,tp)
    if Duel.CanPayEna(tp,"{G}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
      aux.SearchToHand(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end)(x) and x:GetLevel()==2 end,1)
    end
  end)
  c:RegisterEffect(e1)
end
