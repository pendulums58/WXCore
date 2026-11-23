-- WD04-018 堕絡
-- 対象のあなたのアップ状態のシグニ１体をダウンする。そうした場合、そのシグニのパワー以下の対象の対戦相手のシグニ１体をバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 두 대상을 같이 고른다: 내 업 시그니, 그다음 그 파워 이하인 상대 시그니(FAQ 1·4·5)
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local mine=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsUp() end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
  if not mine then return end
  local p=mine:GetPower()
  Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=p end,tp,0,LOCATION_SZONE,1,1,nil)
end
-- 처리: 내 시그니를 다운하고, 그랬으면 상대 시그니의 파워를 다시 비교해 바니시(FAQ 2). 내 시그니가 없으면 아무것도 없다(FAQ 3)
function s.op(e,tp)
  local mine,opp
  for tc in Duel.GetTargets():Iter() do
    if tc:GetControler()==tp then mine=mine or tc else opp=opp or tc end
  end
  if not (mine and mine:IsRelateToEffect(e) and mine:IsUp()) then return end
  Duel.Down(mine)
  if opp and opp:IsRelateToEffect(e) and opp:GetPower()<=mine:GetPower() then Duel.Banish(opp) end
end
