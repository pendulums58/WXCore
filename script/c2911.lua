-- WX17-019 リフューズ・スペル
-- ベット―《コインアイコン》
-- あなたがベットする場合、このアーツの使用コストは《青×0》になる。
-- スペル１つを対象とし、それの効果を打ち消す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetBetCost("")
  -- 「ベットする場合、使用コストは《青×0》」: ベット 코스트 표기로 근사
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_CHECK,LOCATION_CHECK,0,0,nil)
  end)
  e1:SetOperation(function(e,tp)
    Duel.NegateSpell()
  end)
  c:RegisterEffect(e1)
end
