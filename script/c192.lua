-- PR-316 サチュレイト・ガット
-- 以下の２つから１つを選ぶ。
-- ①あなたのトラッシュから＜毒牙＞のシグニを２枚まで対象とし、それらを手札に加える。
-- ②手札をすべて捨てる。その後、あなたのトラッシュから＜毒牙＞のシグニを２枚まで対象とし、それらを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  -- 코스트로 낸 카드도, ②로 버린 카드도 대상이 된다(FAQ 2·3)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==1 then
      local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
      if h:GetCount()>0 then Duel.SendToTrash(h,REASON_EFFECT+REASON_DISCARD) end
    end
    local g=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_DOKUGA) end,tp,LOCATION_TRASH,0,0,2,nil)
    for tc in g:Iter() do
      if e:GetLabel()==0 then Duel.SendToHand(tc) else Duel.PutOnField(tc,tp) end
    end
  end)
  c:RegisterEffect(e1)
end
