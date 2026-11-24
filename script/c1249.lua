-- WD14-007 デモン・トゥーム
-- あなたの＜悪魔＞のシグニ１体をバニッシュする。そうした場合、あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  -- 대상을 고르지 않는다. 바니시하지 못하면 더하지 않는다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_AKUMA),tp,LOCATION_SZONE,0,nil)
    if g:GetCount()==0 then return end
    if Duel.Banish(Duel.SelectCards(tp,g,1,1))>0 then Duel.SendToLife(Duel.GetDecktopGroup(tp,1)) end
  end)
  c:RegisterEffect(e1)
end
