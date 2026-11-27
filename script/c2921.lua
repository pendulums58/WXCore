-- WX17-034 羅菌姫　ボツリネス
-- 【常】：【シャドウ】（このシグニは対戦相手によって対象にされない）
-- 【常】：このシグニはアタックできない。
-- 【自】：対戦相手の場に【ウィルス】１つが置かれたとき、この上に【貯菌】１つを置く。
-- 【起】《アタックフェイズアイコン》この上から【貯菌】１つを取り除く：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－5000する。
-- 【起】この上から【貯菌】２つを取り除く：対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
-- ライフバースト：カードを１枚引き、対戦相手のすべてのシグニゾーンに【ウィルス】を１つずつ置く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_SHADOW)
  e1:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_CANNOT_ATTACK)
  e2:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e2)
  -- 【貯菌】은 이 카드마다 센다(장을 떠나도 남는다. 근사)
  local store={n=0}
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_VIRUS_PLACED)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCondition(function(e,tp,eg,ep) return ep~=tp end)
  e3:SetOperation(function(e,tp)
    store.n=store.n+1
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetDescription(aux.Ability(id,3))
  e4:SetRange(LOCATION_SZONE)
  e4:SetTiming(TIMING_ATTACK)
  e4:SetCost(s.cost(store,1))
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-5000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e4)
  local e5=Effect.CreateEffect(c)
  e5:SetType(EFFECT_TYPE_IGNITION)
  e5:SetDescription(aux.Ability(id,4))
  e5:SetRange(LOCATION_SZONE)
  e5:SetCost(s.cost(store,2))
  e5:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e5:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e5)
  local e6=Effect.CreateEffect(c)
  e6:SetType(EFFECT_TYPE_LIFEBURST)
  e6:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    for _,z in ipairs(Duel.GetSigniZones(1-tp)) do Duel.PlaceVirus(z) end
  end)
  c:RegisterEffect(e6)
end
function s.cost(store,n)
  return function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return store.n>=n end
    store.n=store.n-n
  end
end
