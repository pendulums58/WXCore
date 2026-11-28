-- WXK10-042 堕ちし蒼天　ネフィリム
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをあなたのトラッシュにある青のシグニ２枚につき－1000する。
-- 【出】：各プレイヤーは手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local n=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_BLUE) end,tp,LOCATION_TRASH,0,nil):GetCount()
      if n>=2 then aux.AddPower(e,tc,-1000*math.floor(n/2)) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    aux.Discard(tp,1)
    aux.Discard(1-tp,1)
  end)
  c:RegisterEffect(e2)
end
