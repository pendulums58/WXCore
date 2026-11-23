-- WD09-018 ゲット・トゥインクル
-- あなたのデッキからレベル３以下の白のシグニ１枚を探して公開し手札に加える。その後、あなたの場にレゾナがある場合、
-- 追加でレベル３以下の白のシグニ１枚を探して公開し手札に加える。その後、デッキをシャッフルする。
-- ライフバースト：あなたのデッキから白のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) aux.SearchToHand(tp,s.white,1) end)
  c:RegisterEffect(e2)
end
function s.white(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end
function s.low(x) return s.white(x) and x:GetLevel()<=3 end
function s.pick(tp)
  local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(s.low,tp,LOCATION_MDECK,0,nil),0,1)
  if g:GetCount()>0 then
    Duel.RevealCards(g)
    Duel.SendToHand(g)
  end
end
-- 없으면 찾지 않고 섞기만 한다(FAQ 1). 섞기는 마지막에 한 번
function s.op(e,tp)
  Duel.ConfirmCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil))
  s.pick(tp)
  if Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_RESONA) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then s.pick(tp) end
  Duel.SendToDeckShuffle(Group.CreateGroup(),tp)
end
