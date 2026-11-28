-- WXK05-004 ジャイアント・キリング
-- あなたのセンタールリグが＜エルドラ＞の場合、このアーツの使用コストは《青×2》減る。
-- 以下の４つから２つまで選ぶ。
-- ①対戦相手は手札を２枚捨てる。
-- ②対戦相手のセンタールリグ１体を対象とし、それをダウンし凍結する。
-- ③対戦相手のシグニ１体を対象とし、それをデッキの一番上に置く。手札を１枚捨てる。
-- ④スペル１つを対象とし、それの効果を打ち消す。そうした場合、【エナチャージ４】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetMinCost(function(e,tp,base) if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_ELDORA) end)() then return Duel.ReduceCost(base,"{U}{U}",1) end return base end)
  e1:SetDeclare(function(e,tp)
    if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_ELDORA) end)() then Duel.SetUseCost(Duel.ReduceCost(Duel.GetUseCost(),"{U}{U}",1)) end
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    if m&2~=0 then Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil) end
    if m&4~=0 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp,eg)
    local m=e:GetLabel()
    if m&1~=0 then aux.Discard(1-tp,2) end
    for x in Duel.GetTargets():Iter() do
      if x:IsRelateToEffect(e) then
        if x:IsLocation(LOCATION_LRIG) then Duel.Down(x) Duel.Freeze(x) else Duel.SendToDeckPosition(x,1) end
      end
    end
    if m&4~=0 then aux.Discard(tp,1) end
    if m&8~=0 and Duel.GetCutinSpell() then
      Duel.NegateSpell()
      Duel.EnaCharge(tp,4)
    end
  end)
  c:RegisterEffect(e1)
end
