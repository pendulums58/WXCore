-- WXK04-035 幻水姫　モササ
-- 【自】《ターン１回》：このシグニのパワーが25000以上になったとき、対戦相手のシグニ１体を対象とし、それをゲームから除外する。
-- 【起】手札を１枚捨てる：ターン終了時まで、このシグニのパワーを＋6000する。
-- ライフバースト：カードを１枚引く。あなたのライフクロスが４枚以下の場合、追加で【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local w=Effect.CreateEffect(c)
  w:SetType(EFFECT_TYPE_SINGLE)
  w:SetCode(EFFECT_POWER_WATCH)
  w:SetRange(LOCATION_SZONE)
  w:SetValue(25000)
  c:RegisterEffect(w)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_POWER_REACHED)
  e1:SetCountLimit(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.Exclude(tc)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(aux.DiscardCost(1))
  e2:SetOperation(function(e,tp,eg)
    aux.AddPower(e,e:GetHandler(),6000)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=4 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e9)
end
