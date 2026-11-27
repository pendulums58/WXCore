-- WX22-023 フンフ＝ヨルムガン
-- 【常】：対戦相手のシグニのパワーが－（マイナス）される場合、代わりに２倍－（マイナス）される。
-- 【自】：あなたの＜毒牙＞のシグニ１体が場に出るかアタックしたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－2000する。
-- 【起】《ターン１回》《メインフェイズアイコン》《アタックフェイズアイコン》《黒》：あなたのトラッシュからレベル４以下の＜毒牙＞のシグニ１枚を対象とし、それを場に出す。
-- ライフバースト：あなたのトラッシュからシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_DOUBLE_MINUS)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,LOCATION_SZONE)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end)(x) end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-2000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,1))
  e3:SetCode(EVENT_ATTACK)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end)(x) end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-2000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetDescription(aux.Ability(id,2))
  e4:SetRange(LOCATION_SZONE)
  e4:SetCountLimit(1)
  e4:SetEnaCost("{B}")
  e4:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end)(x) and x:GetLevel()<=4 end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e4)
  local e5=Effect.CreateEffect(c)
  e5:SetType(EFFECT_TYPE_LIFEBURST)
  e5:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e5:SetOperation(function(e,tp)
    local x=Duel.GetFirstTarget()
    if not (x and x:IsRelateToEffect(e)) then return end
    if Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) else Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e5)
end
