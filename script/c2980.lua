-- WX18-020 ミュウ＝フリー
-- 【常】：対戦相手はコストの合計が場にある【チャーム】の数以下のスペルを使用できない。
-- 【自】：このルリグがアタックしたとき、あなたのトラッシュから＜凶蟲＞のシグニ１枚を対象とし、それを手札に加える。
-- 【出】：あなたのルリグデッキから＜凶蟲＞のレゾナ１枚を出現条件を無視して場に出す。
-- 【起】《アタックフェイズアイコン》エクシード１：【チャーム】が付いている対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CANNOT_USE)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(0,1)
  e1:SetTarget(function(e,x) return x:IsType(TYPE_SPELL) and x:GetCostTotal()<=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetCharm()~=nil end,0,LOCATION_SZONE,LOCATION_SZONE,nil):GetCount() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KYOUCHU)) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_RESONA) and c:IsClass(0,RACE_KYOUCHU) end,tp,LOCATION_LDECK,0,nil),0,1):GetFirst()
    if x then Duel.PutOnField(x,tp,false) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetDescription(aux.Ability(id,3))
  e4:SetRange(LOCATION_LRIG)
  e4:SetExceedCost(1)
  e4:SetTiming(TIMING_ATTACK)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetCharm()~=nil end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e4)
end
