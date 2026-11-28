-- PR-470B 進化する筋肉　紗倉ひびき（コロコロアニキ2019年夏号 付録）
-- 【常】：このシグニは《現実からの逃避　タマ》の効果以外によっては新たに場に出すことができない。
-- 【自】：このシグニがアタックしたとき、対戦相手のエナゾーンからすべてのカードをトラッシュに置く。
-- 【出】：対戦相手のすべてのシグニをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 《現実からの逃避　タマ》의 효과 이외로는 새로 낼 수 없다: 출현 조건이 없어 효과로만 나온다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ENA,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  -- 시그니 존의 시그니(FAQ 1)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
