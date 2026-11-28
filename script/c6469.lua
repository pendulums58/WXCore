-- WXK04-013 英血の器　優羽莉　Ｌｖ１’
-- 【出】手札を１枚捨てる：カードを１枚引く。
-- 【起】《ターン１回》《赤×0》：あなたの＜紅蓮＞のシグニ１体を対象とし、それを血晶武装［手札］する。
-- （指定された領域［手札］からシグニの下にそれと同名のカード１枚を置くことでそのシグニは血晶武装状態になる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1))
  e1:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_GUREN) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.BloodArm(tp,tc,LOCATION_HAND)
    end
  end)
  c:RegisterEffect(e2)
end
