-- WDK-F03-20 フライング・トリガー
-- 以下の２つから１つを選ぶ。
-- ①対象のあなたの＜遊具＞のシグニ１体を場からトラッシュに置く。そうした場合、対戦相手は対象の自分のシグニ１体を手札に戻す。
-- ②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(s.mode)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
s.toy=aux.ClassFilter(0,RACE_YUGU)  -- ＜遊具＞のシグニ
-- 모드를 고른 뒤 내 시그니를 대상으로 하고, 상대도 자기 시그니 1체를 대상으로 한다(FAQ 1)
function s.mode(e,tp)
  e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1)))
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local op=e:GetLabel()
  if op==0 then
    Duel.SelectTarget(tp,s.toy,tp,LOCATION_SZONE,0,1,1,nil)
    Duel.SelectTarget(1-tp,Card.IsSigni,1-tp,LOCATION_SZONE,0,1,1,nil)
  end
end
function s.op(e,tp)
  if e:GetLabel()==1 then
    Duel.EnaCharge(tp,1)
    return
  end
  local mine, theirs
  for tc in Duel.GetTargets():Iter() do
    if tc:GetControler()==tp then mine=mine or tc else theirs=theirs or tc end
  end
  -- 「Aする。そうした場合、Bする」: 내 시그니를 트래시에 놓지 못했으면 돌려보내지 않는다(FAQ 2)
  if not (mine and mine:IsRelateToEffect(e)) then return end
  Duel.SendToTrash(mine)
  if not mine:IsLocation(LOCATION_TRASH) then return end
  if theirs and theirs:IsRelateToEffect(e) then Duel.SendToHand(theirs) end
end
