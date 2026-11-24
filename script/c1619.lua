-- WDK07-E06 ドント・イート
-- 手札から＜調理＞のシグニを１枚捨てる。そうした場合、対象の対戦相手のシグニ１体をダウンし、対象の対戦相手のシグニ１体をデッキの一番上に置く。
local s,id=GetID()
s.chouri=aux.ClassFilter(0,RACE_CHOURI)  -- ＜調理＞のシグニ
function s.initial_effect(c)
  local down,back  -- 다운할 시그니, 덱에 놓을 시그니(같은 시그니여도 된다. FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 버리기 전에 고른다(FAQ 1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    down=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    back=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
  end)
  -- 패는 비공개라 버리지 않아도 된다
  e1:SetOperation(function(e,tp)
    local g=Duel.SelectDiscard(tp,0,1,s.chouri)
    if g:GetCount()==0 or Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD)==0 then return end
    if down and down:IsRelateToEffect(e) then Duel.Down(down) end
    if back and back:IsRelateToEffect(e) then Duel.SendToDeckPosition(back,1) end
  end)
  c:RegisterEffect(e1)
end
