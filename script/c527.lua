-- WD18-006 千軍万馬
-- ターン終了時まで、あなたのすべての＜調理＞のシグニは「【自】：このシグニがアタックしたとき、自身よりパワーの低い対戦相手のシグニ１体を対象とし、それをバニッシュする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- [まで] 쓴 때 장에 있는 ＜調理＞만(FAQ 1). 여러 장 쓰면 그 수만큼 얻는다(FAQ 2)
function s.op(e,tp)
  for tc in Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_CHOURI),tp,LOCATION_SZONE,0,nil):Iter() do
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetDescription(aux.Ability(id,0))
    e1:SetCode(EVENT_ATTACK)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTarget(s.tg)
    e1:SetOperation(aux.BanishOp)
    tc:GrantEffect(e1)
  end
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local pw=e:GetHandler():GetPower()
  Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<pw end,tp,0,LOCATION_SZONE,1,1,nil)
end
