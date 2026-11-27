-- WX22-Re06 アンシエント・ウェーブ
-- あなたの黒のシグニを好きな数対象とし、それらを場からトラッシュに置く。その後、この方法でトラッシュに置いたシグニのレベルの合計が３以上の場合、対戦相手のシグニ１体を対象とし、それをバニッシュする。６以上の場合、カードを２枚引く。９以上の場合、対戦相手のライフクロス１枚をクラッシュする。１２以上の場合、あなたのトラッシュからシグニを３枚まで対象とし、それらを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_SZONE,0,0,3,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    local sum=0
    for x in g:Iter() do sum=sum+x:GetLevel() end
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    if sum>=3 then local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Banish(tc) end end
    if sum>=6 then Duel.Draw(tp,2) end
    if sum>=9 then Duel.Crush(1-tp,1) end
    if sum>=12 then for x in Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,0,3,nil):Iter() do Duel.PutOnField(x,tp) end end
  end)
  c:RegisterEffect(e1)
end
