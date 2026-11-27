-- WX02-026 ウィッシュ・クライシス
-- あなたの＜天使＞のシグニ１体を対象とし、それを場からトラッシュに置く。そうした場合、あなたのデッキから＜天使＞のシグニを２枚まで探して場に出し、デッキをシャッフルする。
-- ライフバースト：あなたのデッキから＜天使＞のシグニ１枚を探して場に出し、デッキをシャッフルする。そのシグニの【出】能力は発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  -- 함께 낼 수 있는 조합만(FAQ 1~3). 打ち消されたり 놓지 못하면 아무것도(FAQ 5·6)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and Duel.SendToTrash(tc,REASON_EFFECT)>0) then return end
    Duel.SetSelectCheck(function(g) return Duel.CanPutAll(g,tp) end)
    for x in aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,2):Iter() do Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,1):GetFirst()
    if x then Duel.PutOnField(x,tp,true) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
end
