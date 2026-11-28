-- PR-433 ストール・ストーリー（ウィクロスカード大全Ⅶ 付録）
-- 対戦相手のルリグトラッシュからアーツ１枚を対象とし、このターン、それをあなたのルリグデッキにあるかのように使用してもよい。この方法であなたがそのアーツを使用する際、そのコストの色を無視して支払ってもよい。
-- （限定条件、使用タイミングは無視しない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 이 턴 동안 상대 루리그 트래시의 그 아츠를 내 루리그 덱에 있는 것처럼 쓴다. 한정 조건·타이밍은 지킨다
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_ARTS) end,tp,0,LOCATION_LTRASH,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_USE_AS_LDECK)
    e1:SetValue(tp)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
  end)
  c:RegisterEffect(e1)
end
