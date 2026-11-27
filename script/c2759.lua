-- WX15-021 瓦釜雷鳴
-- ベット―《コインアイコン》
-- 対象の対戦相手のパワー15000以上のシグニ１体をバニッシュする。あなたがベットしていた場合、追加で対象の対戦相手のパワー12000以上のシグニ１体をバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=15000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    s.b=Duel.IsBet() and Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp,0,LOCATION_SZONE,1,1,s.a):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    for _,x in ipairs({s.a or false,s.b or false}) do if x and x:IsRelateToEffect(e) then Duel.Banish(x) end end
  end)
  c:RegisterEffect(e1)
end
