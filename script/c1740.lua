-- WDK13-007 ハイドロ・サークル
-- ベット―《コインアイコン》
-- （このアーツを使用する際に《コインアイコン》を支払ってもよい）
-- 対戦相手のシグニをレベルの合計が５以下になるように２体まで対象とし、それらをバニッシュする。あなたがベットしていた場合、代わりにレベルの合計が７以下になるように２体まで対象とし、それらをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  -- 남는 시그니가 아니라 대상의 레벨 합계(FAQ 1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local n=Duel.IsBet() and 7 or 5
    Duel.SetSelectCheck(function(sg) local lv=0 for x in sg:Iter() do lv=lv+x:GetLevel() end return lv<=n end)
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
end
