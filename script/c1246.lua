-- WD14-001 虚幸の閻魔　ウリス
-- 【常】：このカードにグロウするためのコストは、あなたのトラッシュにある＜悪魔＞のシグニ６枚につき《黒×1》減る。
-- 【常】：あなたのトラッシュに＜悪魔＞のシグニが１８枚以上あるかぎり、対戦相手は【ガード】ができない。
-- 【常】：あなたのすべての領域にある【ライフバースト】を持たないカードは【ライフバースト】「対戦相手のシグニ１体を対象とし、それをバニッシュする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- 코스트는 그로우를 선언할 때 정해진다. 코스트로 트래시에 간 카드는 세지 않는다(FAQ 1)
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetMinCost(function(e,tp) return s.cost(tp) end)
  e0:SetDeclare(function(e,tp) Duel.SetUseCost(s.cost(tp)) end)
  c:RegisterEffect(e0)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_NO_GUARD)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(0,1)
  e1:SetCondition(function(e) return s.count(e:GetHandlerPlayer())>=18 end)
  c:RegisterEffect(e1)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD)
  e3:SetCode(EFFECT_GRANT_LIFEBURST)
  e3:SetRange(LOCATION_LRIG)
  e3:SetTargetRange(1,0)
  e3:SetLabelObject(e2)
  c:RegisterEffect(e3)
end
function s.count(tp) return Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_AKUMA),tp,LOCATION_TRASH,0,nil):GetCount() end
function s.cost(tp) return string.rep("{B}",math.max(0,3-s.count(tp)//6)) end
