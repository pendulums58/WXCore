-- WDK09-013 コードメイズ　Ｂ・スカイジュ
-- 【自】：あなたの効果１つによって対戦相手のカードが１枚以上デッキに移動したとき、対戦相手のシグニ１体を対象とし、
--         ターン終了時まで、それのパワーを－2000する。（１つの効果で２枚以上移動しても一度しか発動しない）
-- 【出】：対戦相手のトラッシュからカードを２枚まで対象とし、それらをデッキの一番下に置く。（置く順番は対戦相手が選ぶ）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_MOVED_TO_DECK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(s.con)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(s.dtg)
  e2:SetOperation(s.dop)
  c:RegisterEffect(e2)
end
-- 메인 덱으로의 이동만(루리그 덱·덱에서 덱은 아니다. FAQ 2·3)
function s.con(e,tp,eg,ep,ev,re,r,rp)
  if rp~=tp then return false end
  for c in eg:Iter() do if c:GetOwner()~=tp then return true end end
  return false
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
end
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then
    aux.AddPower(e,tc,-2000)  -- [まで] ターン終了時まで
  end
end
function s.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,nil,tp,0,LOCATION_TRASH,1,2,nil)
end
function s.dop(e,tp)
  local g=Group.CreateGroup()
  for tc in Duel.GetTargets():Iter() do
    if tc:IsRelateToEffect(e) then g:AddCard(tc) end
  end
  Duel.SendToDeckBottom(Duel.SelectOrder(1-tp,g),false)
end
