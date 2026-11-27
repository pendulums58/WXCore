-- WX17-055 混成の怪物　フンババ
-- 【ライズ】あなたのレベル２以下の赤のシグニ１体の上に置く
-- 【自】：対戦相手のターンの間、このシグニが場を離れたとき、あなたのトラッシュからこのシグニの下にあった《ライズアイコン》を持たないシグニ１枚を対象とし、それを場に出してもよい。それの【出】能力は発動しない。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddRise(c,function(x) return x:IsSigni() and x:IsColor(COLOR_RED) and x:GetLevel()<=2 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_LEAVE_FIELD)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  -- 「このシグニの下にあった」는 트래시의 《ライズアイコン》 없는 시그니로 근사
  e1:SetOperation(function(e,tp)
    local x=Duel.SelectTarget(tp,function(c) return c:IsSigni() and not c:HasRiseIcon() end,tp,LOCATION_TRASH,0,0,1,nil):GetFirst()
    if x then Duel.PutOnField(x,tp,true) end
  end)
  c:RegisterEffect(e1)
end
