-- WXEX1-65 幻水　Ｄｒ．フィッシュ
-- 【自】：このシグニがアタックしたとき、《青》を支払ってもよい。そうした場合、対戦相手のデッキの一番上のカードをトラッシュに置く。それがこのシグニの正面のシグニとレベルが同じ場合、このシグニの正面のシグニをデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    if not Duel.CanPayEna(tp,"{U}") or not Duel.SelectYesNo(tp) then return end
    local g=Duel.SelectEnaCost(tp,"{U}")
    if g:GetCount()==0 or Duel.SendToTrash(g,REASON_COST)==0 then return end
    local top=Duel.GetDecktopGroup(1-tp,1):GetFirst()
    if not top then return end
    Duel.SendToTrash(top,REASON_EFFECT)
    local opp=e:GetHandler():GetFrontCard()
    if opp and opp:IsSigni() and top:GetLevel()==opp:GetLevel() then
      Duel.SendToDeckPosition(opp,1)
    end
  end)
  c:RegisterEffect(e1)
end
