-- WDK08-Y10 ファントム・ガーデン
-- ベット―《コインアイコン》
-- あなたのトラッシュからあなたのセンタールリグと共通する色を持つそれぞれレベルの異なるシグニを３枚まで対象とし、それらを手札に加える。
-- あなたがベットしていた場合、３枚の代わりに４枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetTarget(s.tg)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
    end
  end)
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
-- 「３枚まで」: 0~3장(FAQ 2). 무색 루리그는 색이 없어 무색 시그니도 안 된다(FAQ 4)
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local center=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
  local col=center and center:GetColor() or 0
  Duel.SetSelectCheck(s.distinct)
  Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetColor()&col~=0 end,tp,LOCATION_TRASH,0,0,Duel.IsBet() and 4 or 3,nil)
end
