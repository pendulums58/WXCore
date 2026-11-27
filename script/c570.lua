-- WX16-025 幻怪姫　スノークイーン
-- 【自】：このシグニが場を離れたとき、あなたの手札からこのシグニよりパワーの低いシグニ１枚を場に出してもよい。
-- 【出】手札から＜怪異＞のシグニを２枚捨てる：対戦相手のシグニ１体を対象とし、それを手札に戻す。
-- 【起】《白》《白》：あなたのトラッシュから《幻怪姫　スノークイーン》以外の＜怪異＞のシグニ１枚を対象とし、それを手札に加える。
-- ライフバースト：あなたのトラッシュから＜怪異＞のシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_LEAVE_FIELD)
  e1:SetOperation(function(e,tp)
    local p=e:GetHandler():GetPower()  -- 직전 정보(FAQ 1)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetPower()<p end,tp,LOCATION_HAND,0,nil)
    local x=Duel.SelectCards(tp,g,0,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(aux.DiscardCost(2,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetEnaCost("{W}{W}")
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end)(x) and not x:IsCardName(id) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e4:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e4)
end
