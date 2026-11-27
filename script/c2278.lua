-- WX08-032 ワーム・ホール
-- このスペルの使用コストはあなたの場にある＜凶蟲＞のシグニ１体か対戦相手の場にある【チャーム】１枚につき《黒×1》減る。
-- 対戦相手のシグニ１体を対象とし、それをバニッシュする。このターンと次のターンの間、対戦相手はそれがあったシグニゾーンにシグニを新たに配置することができない。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－8000する。それに【チャーム】が付いている場合、代わりに－15000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{B}",Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KYOUCHU)) end,tp,LOCATION_SZONE,0,nil):GetCount()+(function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do if x:GetCharm() then n=n+1 end end return n end)(1-tp)) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local z=tc:GetZone()
    if Duel.Banish(tc)==0 then return end
    -- [の間] 이 턴과 다음 턴, 그 존에 새로 배치 못 한다
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_ZONE_LOCK)
    e1:SetTargetRange(0,1)
    e1:SetValue(z)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,tc:GetCharm() and -15000 or -8000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e2)
end
