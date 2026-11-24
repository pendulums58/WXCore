-- WD22-024-U 千夜の夜王　イフリード
-- 【自】：このカードがあなたのデッキからトラッシュに置かれたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－2000する。
-- 【起】《アタックフェイズアイコン》あなたのトラッシュにある《千夜の夜王　イフリード》４枚をゲームから除外する：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－15000する。この能力はこのカードがトラッシュにある場合にしか使用できない。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  -- 한정 조건과 관계없이, 그 뒤 다른 곳으로 가도 발동한다(FAQ 1·2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MDECK) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-2000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_TRASH)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:GetCode()==id end,tp,LOCATION_TRASH,0,nil)
    if chk==0 then return g:GetCount()>=4 end
    Duel.Exclude(Duel.SelectCards(tp,g,4,4),REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-15000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e3)
end
