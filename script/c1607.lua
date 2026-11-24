-- WDK05-R11 彩英の探求　ノーベル
-- 【自】：このシグニがアタックしたとき、《青》を支払ってもよい。そうした場合、あなたのデッキの下からカードを２枚トラッシュに置く。その後、この方法でトラッシュに置かれたシグニのレベルの合計と同じレベルの対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをダウンする。カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  -- 2장 다 시그니면 반드시 합친다(FAQ 1). 시그니가 없으면 바니시하지 않는다(FAQ 2)
  e1:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
    local g=Duel.GetDeckbottomGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local lo,hi=s.sum(g)
    if not lo then return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and lo<=x:GetLevel() and x:GetLevel()<=hi end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) end
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
-- 시그니 레벨의 합계. 1~4로 칠 수 있는 카드가 있으면 lo~hi 어느 것이든 된다. 시그니가 없으면 nil
function s.sum(g)
  local lo,hi,n=0,0,0
  for x in g:Filter(function(x) return x:IsLocation(LOCATION_TRASH) and x:IsSigni() end,nil):Iter() do
    local any,lv=x:HasKeyword(EFFECT_ANY_LEVEL),x:GetLevel()
    lo=lo+(any and math.min(1,lv) or lv)
    hi=hi+(any and math.max(4,lv) or lv)
    n=n+1
  end
  if n==0 then return end
  return lo,hi
end
