-- WD08-014 コードアンチ　テキサハンマ
-- 【自】：このカードがデッキからトラッシュに置かれたとき、このカードをトラッシュから場に出してもよい。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- 놓은 효과가 끝난 뒤 처리. 그 사이 리프레시로 덱에 돌아갔으면 낼 수 없다(FAQ 1).
  -- 장의 시그니를 치우고 낼 수는 없다(FAQ 2: PutOnField가 빈 존만 고른다)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MDECK) end)
  e1:SetOperation(function(e,tp)
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_TRASH) and Duel.SelectYesNo(tp) then Duel.PutOnField(c,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
