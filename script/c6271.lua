-- WXK01-092 幻怪　ベヒーモス
-- 【自】：このシグニがアタックしたとき、このターンにあなたがアーツを使用していた場合、《緑》《緑》《緑》を支払ってもよい。そうした場合、あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 여러 장 써도 1번(FAQ 2)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCondition(function(e,tp) return Duel.GetArtsUsedCount(tp)>0 end)
  e1:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{G}{G}{G}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}{G}{G}"),REASON_COST)
    local g=Duel.GetDecktopGroup(tp,1)
    if g:GetCount()>0 then Duel.SendToLife(g) end
  end)
  c:RegisterEffect(e1)
end
