-- WDK05-R14 皮英の潤滑　イグ・バナナン
-- 【出】：カードを１枚引き、手札からカード１枚をデッキの一番下に置く。
-- 【起】《ターン１回》《青×0》：あなたのデッキの下からカードを２枚トラッシュに置く。その後、この方法でトラッシュに置かれたシグニのレベルの合計が４の場合、対戦相手のシグニを２体まで対象とし、それらを凍結する。
-- （凍結されたシグニは次の自分のアップフェイズにアップしない）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    local n=math.min(1,g:GetCount())
    if n>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,Duel.SelectCards(tp,g,n,n)),false) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  -- 시그니 1장과 스펠 1장이면 그 시그니의 레벨만 본다(FAQ 1)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDeckbottomGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local lo,hi=s.sum(g)
    if not lo or lo>4 or hi<4 then return end
    for tc in Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil):Iter() do Duel.Freeze(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
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
