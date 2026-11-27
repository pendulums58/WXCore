-- WX10-047 幻獣　フラミー
-- 【常】：あなたの場にパワー50000以上のシグニがあるかぎり、あなたのシグニは【ランサー】を得る。
-- 【出】：シグニ１体を対象とし、ターン終了時まで、それのパワーを＋10000する。
-- 【起】《緑》：ターン終了時まで、あなたのすべてのシグニのパワーを＋10000する。
-- ライフバースト：次のターンの間、あなたのシグニのパワーを＋10000する。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_LANCER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() end)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetPower()>=50000 end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,10000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetEnaCost("{G}")
  -- [まで] 처리할 때 장에 있는 시그니
  e3:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,tc,10000) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    -- [の間] 「次のターンの間」
    local now=Duel.GetTurnCount()
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_POWER)
    e1:SetTargetRange(LOCATION_SZONE,0)
    e1:SetTarget(function(e,x) return x:IsSigni() end)
    e1:SetCondition(function() return Duel.GetTurnCount()==now+1 end)
    e1:SetValue(10000)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e4)
end
