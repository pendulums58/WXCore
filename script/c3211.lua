-- WX21-051 神技の鞭刑　≡アナフィエル≡
-- 【出】：対戦相手のパワー3000以下のシグニ１体を対象とし、あなたの場にある＜天使＞のシグニが持つ色が合計２種類以上ある場合、それをバニッシュする。
-- ライフバースト：対戦相手のパワー3000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(aux.BanishPowerTarget(3000))
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if (function() local m=0 for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_SZONE,0,nil):Iter() do m=m|x:GetColor() end local n=0 while m>0 do n=n+(m&1) m=m>>1 end return n end)()>=2 then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(aux.BanishPowerTarget(3000))
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
end
