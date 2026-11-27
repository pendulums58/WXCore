-- WX12-Re14 羅原　Ｎｉ
-- 【常】：あなたのトラッシュに＜原子＞のシグニが７種類以上あるかぎり、このシグニの基本パワーは15000になる。
-- 【常】：あなたの＜原子＞のシグニは対戦相手のスペルの効果を受けない。
-- 【起】《青》：対戦相手のトラッシュからスペル１枚を対象とし、それを対戦相手のデッキの一番上に置く。
-- ライフバースト：カードを２枚引き、手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘
  aux.BasePower(c,15000,function(e) local seen,n={},0 for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):Iter() do if not seen[x:GetCode()] then seen[x:GetCode()]=true n=n+1 end end return n>=7 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end)(x) end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsType(TYPE_SPELL) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{U}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) end,tp,0,LOCATION_TRASH,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckPosition(tc,1) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e3)
end
