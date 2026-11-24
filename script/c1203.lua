-- WD10-018 運命の重複
-- 対戦相手のパワー3000以下のシグニ１体を対象とし、それをバニッシュする。あなたの場にクロス状態のシグニがある場合、代わりに対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：あなたのデッキから《クロスアイコン》を持つシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local max=s.max(tp)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=max end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  -- 컷인으로 크로스 상태가 풀리면 3000 이하일 때만 바니시한다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:GetPower()<=s.max(tp) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:HasCrossIcon() end,1)
  end)
  c:RegisterEffect(e2)
end
function s.max(tp)
  local n=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsCross() end,tp,LOCATION_SZONE,0,nil):GetCount()
  return n>0 and 10000 or 3000
end
