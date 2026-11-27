-- WX10-051 クローズ・ゾーン
-- シグニゾーン１つを指定する。次のターンの間、対戦相手は指定されたシグニゾーンにシグニを新たに配置することができない。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－7000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local z=Duel.SelectZone(tp,Duel.GetSigniZones(1-tp))
    if not z then return end
    -- [の間] 「次のターンの間」
    local now=Duel.GetTurnCount()
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_ZONE_LOCK)
    e1:SetTargetRange(0,1)
    e1:SetValue(z)
    e1:SetCondition(function() return Duel.GetTurnCount()==now+1 end)
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
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-7000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e2)
end
