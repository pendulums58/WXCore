-- WX13-046 轟右砲　ドスラフ
-- 《クロスアイコン》《轟左砲　ドーラ》の右
-- 【クロス自】：このシグニがアタックしたとき、対戦相手のパワー5000以下のシグニを１体まで対象とし、それをバニッシュし、ターン終了時まで、このシグニのパワーを＋4000する。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,1412,CROSS_RIGHT)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCondition(function(e) return e:GetHandler():IsCross() end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=5000 end,tp,0,LOCATION_SZONE,0,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,4000) end
  end)
  c:RegisterEffect(e1)
end
