-- WXK03-072 幻怪　モモザル
-- 【自】《ターン１回》：場にあるあなたのシグニ１体が他のシグニゾーンに移動したとき、ターン終了時まで、あなたのすべてのシグニのパワーを＋2000する。
-- 【出】：あなたの他のシグニ１体を対象とし、それとこのシグニの場所を入れ替える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_SIGNI_MOVED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) return eg:GetFirst():GetControler()==tp end)
  e1:SetOperation(function(e,tp,eg)
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,x,2000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 다른 시그니가 있으면 반드시(FAQ 1)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x~=e:GetHandler() end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if e:GetHandler():IsLocation(LOCATION_SZONE) then Duel.SwapSigni(e:GetHandler(),tc) end
    end
  end)
  c:RegisterEffect(e2)
end
