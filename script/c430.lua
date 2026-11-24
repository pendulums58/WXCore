-- WD02-014 羅石　アメジスト
-- 【出】：対戦相手のパワー1000以下のシグニ１体を対象とし、それをバニッシュしてもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(aux.BanishPowerTarget(1000))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 코스트가 없으니 대상은 반드시 고르고, 바니시할지는 처리할 때 고른다(FAQ 2)
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) and Duel.SelectYesNo(tp) then Duel.Banish(tc) end
end
