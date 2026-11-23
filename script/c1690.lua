-- WDK09-022 ＢＲＩＧＨＴＮＥＳＳ
-- 以下の２つから１つを選ぶ。
-- ①対象のあなたの＜迷宮＞のシグニ１体を場からトラッシュに置く。そうした場合、あなたのトラッシュから対象の＜迷宮＞のシグニ１枚を手札に加える。
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
s.maze=aux.ClassFilter(0,RACE_MEIKYU)  -- ＜迷宮＞のシグニ
-- 모드를 고르고, ①이면 장과 트래시의 시그니를 동시에 대상으로(FAQ 3). 트래시 쪽은 사용 시점에 이미 있어야 한다(FAQ 1·2)
function s.mode(e,tp)
  e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1)))
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local op=e:GetLabel()
  if op==0 then
    Duel.SelectTarget(tp,s.maze,tp,LOCATION_SZONE,0,1,1,nil)
    Duel.SelectTarget(tp,s.maze,tp,LOCATION_TRASH,0,1,1,nil)
  end
end
function s.op(e,tp)
  if e:GetLabel()==1 then
    Duel.EnaCharge(tp,1)
    return
  end
  local field, trash
  for tc in Duel.GetTargets():Iter() do
    if tc:IsLocation(LOCATION_SZONE) then field=field or tc
    elseif tc:IsLocation(LOCATION_TRASH) then trash=trash or tc end
  end
  -- 「Aする。そうした場合Bする」: 장에서 트래시에 놓지 못했으면 패에 넣지 않는다(FAQ 4)
  if not (field and field:IsRelateToEffect(e)) then return end
  Duel.SendToTrash(field)
  if not field:IsLocation(LOCATION_TRASH) then return end
  if trash and trash:IsRelateToEffect(e) then Duel.SendToHand(trash) end
end
