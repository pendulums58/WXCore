-- WX15-075 一揆の黄兵　コウキン
-- 【自】：このシグニがバニッシュされたとき、《赤》を支払ってもよい。そうした場合、あなたのデッキからレベル２の＜武勇＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetOperation(function(e,tp)
    if Duel.CanPayEna(tp,"{R}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}"),REASON_COST)
      aux.SearchToHand(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_BUYU)) end)(x) and x:GetLevel()==2 end,1)
    end
  end)
  c:RegisterEffect(e1)
end
