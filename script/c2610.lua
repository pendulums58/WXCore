-- WX13-036 フィア＝パトラ
-- 【自】：あなたの効果によって対戦相手のシグニのパワーが減ったとき、ターン終了時まで、このシグニのパワーを減った値と同じだけ＋する。
-- 【出】：あなたのトラッシュからレベル１の＜毒牙＞のシグニ１枚を対象とし、それを手札に加える。
-- 【起】《ターン１回》ターン終了時まで、このシグニのパワーを20000減らす：対戦相手は自分のシグニ１体を対象とし、手札を１枚捨て、それをトラッシュに置く。（パワーは０未満まで減らせない）
-- ライフバースト：あなたのトラッシュから＜毒牙＞のシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- 【自】 「あなたの効果で対戦相手のシグニのパワーが減ったとき」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end)(x) and x:GetLevel()==1 end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  -- 파워를 줄이는 것이 코스트(0 미만으로는 못 줄인다)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetPower()>=20000 end
    aux.AddPower(e,e:GetHandler(),-20000)
  end)
  e2:SetOperation(function(e,tp)
    local x=Duel.SelectTarget(1-tp,Card.IsSigni,1-tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    aux.Discard(1-tp,1)
    if x then Duel.SendToTrash(x,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e3)
end
