-- WD08-011 コードアンチ　アシレン
-- 【出】：あなたのトラッシュからそれぞれレベルの異なる＜古代兵器＞のシグニ４枚を好きな順番でデッキの一番下に置く。そうした場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.distinct(g)
  local lv={}
  for x in g:Iter() do
    if lv[x:GetLevel()] then return false end
    lv[x:GetLevel()]=true
  end
  return true
end
-- 0장이나 레벨이 다른 4장(WD07-012 FAQ 4와 같은 문구)
function s.op(e,tp)
  local g=Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_KODAIHEIKI),tp,LOCATION_TRASH,0,nil)
  Duel.SetSelectCheck(function(sg) return sg:GetCount()==0 or (sg:GetCount()==4 and s.distinct(sg)) end)
  local sg=Duel.SelectCards(tp,g,0,4)
  if sg:GetCount()~=4 then return end
  Duel.SendToDeckBottom(Duel.SelectOrder(tp,sg),false)
  Duel.Draw(tp,1)
end
