-- WX08-073 突進
-- あなたの【ランサー】を持つシグニ１体を対象とし、ターン終了時まで、それのパワーを＋10000し、そのシグニは「【自】：このシグニが対戦相手のライフクロスをクラッシュしたとき、あなたのデッキの上からカードを２枚エナゾーンに置く。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasKeyword(EFFECT_LANCER) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,10000)
        -- [まで] 그 시그니가 크러시했을 때
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
        e1:SetCode(EVENT_CRUSHED)
        e1:SetCondition(function(e2,tp2,eg2,ep2) return ep2~=tp and Duel.GetCrusher()==tc end)
        e1:SetOperation(function() Duel.EnaCharge(tp,2) end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp) end
  end)
  c:RegisterEffect(e1)
end
