-- WXK05-020 憂慮の花嫁　アルフォウ
-- 【起】《ターン１回》《黒×0》：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをあなたのトラッシュにあるカード３枚につき－1000する。
-- 【起】このキーを場からルリグトラッシュに置く：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをあなたのトラッシュにあるカード１枚につき－1000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_KEY)
  e1:SetCountLimit(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local n=math.floor(Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil):GetCount()/3)
      if n>0 then aux.AddPower(e,tc,-1000*n) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local n=Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil):GetCount()
      if n>0 then aux.AddPower(e,tc,-1000*n) end
    end
  end)
  c:RegisterEffect(e2)
end
