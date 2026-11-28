-- WXK01-106 中罠　アルババ
-- 【出】：あなたのデッキの上からカードを２枚トラッシュに置く。その後、この方法でレベルが偶数のシグニ２枚がトラッシュに置かれた場合、あなたのトラッシュからレベル２以下のシグニ１枚を対象とし、それを場に出す。（コストのない【出】能力は発動しないことを選べない。デッキが１枚の場合それをトラッシュに置く）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local n=0
    for x in g:Iter() do if x:IsSigni() and x:GetLevel()%2==0 and x:IsLocation(LOCATION_TRASH) then n=n+1 end end
    if n<2 then return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=2 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
end
