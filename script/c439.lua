-- WD14-008 グレイブ・ガット
-- 以下の２つから１つを選ぶ。
-- ①あなたのトラッシュから＜悪魔＞のシグニを２枚まで対象とし、それらを手札に加える。
-- ②手札をすべて捨てる。その後、あなたのトラッシュから＜悪魔＞のシグニを２枚まで対象とし、それらを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then s.pick(tp) end
  end)
  -- ②의 대상은 패를 버린 뒤에 고른다. 패가 0장이어도 된다(FAQ 1)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      for tc in Duel.GetTargets():Iter() do
        if tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
      end
      return
    end
    Duel.SendToTrash(Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil),REASON_EFFECT+REASON_DISCARD)
    for tc in s.pick(tp):Iter() do Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
end
function s.pick(tp) return Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_AKUMA),tp,LOCATION_TRASH,0,0,2,nil) end
