-- WXK04-024 協奏の駄姫　グズ子
-- 【出】：レベルが奇数の対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－3000する。
-- 【起】このキーを場からルリグトラッシュに置く：ターン終了時まで、レベルが奇数の対戦相手のすべてのシグニのパワーを－15000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()%2==1 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-3000)
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
  e2:SetOperation(function(e,tp,eg)
    for x in Duel.GetMatchingGroup(function(y) return y:IsSigni() and y:GetLevel()%2==1 end,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,x,-15000) end
  end)
  c:RegisterEffect(e2)
end
