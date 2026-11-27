-- WX15-093 真英の数式　#フィボナチ#
-- 【起】《ダウン》：あなたの＜英知＞のシグニ１体を対象とし、ターン終了時まで、それは「【常】：このシグニは、このシグニの正面以外の対戦相手のシグニゾーンにもアタックできる。」を得る。
-- （シグニゾーンにアタックした場合、対戦相手にダメージを与えない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.GrantKeyword(e,tc,EFFECT_ATTACK_ZONE) end
  end)
  c:RegisterEffect(e1)
end
