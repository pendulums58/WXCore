-- WX20-020 サティスファクション
-- あなたのセンタールリグのレベルが４以下で、対戦相手のセンタールリグのレベルが５以上の場合、このアーツの使用コストは《無×1》になる。
-- 以下の４つから２つまで選ぶ。
-- ①対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ②カードを２枚引く。
-- ③あなたのデッキの上からカードを２枚エナゾーンに置く。
-- ④あなたのトラッシュからあなたのセンタールリグと共通する色を持つシグニ１枚を対象とし、それを場に出す。そのシグニの【出】能力は発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) if (function() local a=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() local b=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst() return a and b and a:GetLevel()<=4 and b:GetLevel()>=5 end)() then return "{C}" end return base end)
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Banish(tc) end end
    if m&2~=0 then Duel.Draw(tp,2) end
    if m&4~=0 then Duel.EnaCharge(tp,2) end
    if m&8~=0 then local x=Duel.SelectTarget(tp,function(x) local lc=Duel.GetMatchingGroup(nil,x:GetOwner(),LOCATION_LRIG,0,nil):GetFirst() return x:IsSigni() and lc and x:GetColor()&lc:GetColor()~=0 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst() if x then Duel.PutOnField(x,tp,true) end end
  end)
  c:RegisterEffect(e1)
end
