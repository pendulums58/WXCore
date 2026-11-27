-- WX17-025 幻怪姫　オワレ
-- 【レイヤー】あなたの＜怪異＞のシグニは《レイヤーアイコン》の能力を得る
-- 《レイヤーアイコン》【常】：対戦相手のターンの間、このシグニのパワーは＋3000される。
-- 【起】手札から＜怪異＞のシグニを３枚捨てる：対戦相手のシグニを２体を対象とし、それらを手札に戻す。
-- 【起】《ターン１回》《白×0》：あなたのトラッシュからそれぞれレベルの異なる＜怪異＞のシグニ４枚をデッキに加えてシャッフルする。そうした場合、次のあなたのターンまで、このシグニは「【常】：対戦相手のシグニの効果を受けない。」を得る。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【レイヤー】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end)(x) end)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetCondition(function(e) return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(aux.DiscardCost(3,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,2,2,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetCountLimit(1)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end,tp,LOCATION_TRASH,0,nil)
    Duel.SetSelectCheck(function(sg) return sg:GetCount()==0 or (sg:GetCount()==4 and aux.DistinctLevels(sg)) end)
    local pick=Duel.SelectCards(tp,g,0,4)
    local ok=pick:GetCount()==4
    if ok then Duel.SendToDeckShuffle(pick,tp) end
    local h=e:GetHandler()
    if not ok or not h:IsLocation(LOCATION_SZONE) then return end
    -- [まで] 「次のあなたのターンまで」
    local e1=Effect.CreateEffect(h)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE)
    e1:SetValue(function(e2,sc,sp) return sp~=tp and sc:IsSigni() end)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    h:RegisterEffect(e1)
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e4)
end
