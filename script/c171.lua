-- WX21-Re18 無垢なる宝剣
-- このスペルを使用する際、使用コストとして追加でエナゾーンからカードを２枚以上トラッシュに置く。
-- これの使用コストとして追加で白のカードがトラッシュに置かれた場合、対象の対戦相手のシグニ１体を手札に戻す。
-- 赤の場合、対象の対戦相手のパワー12000以下のシグニ１体をバニッシュする。
-- 青の場合、カードを２枚引き、手札を１枚捨てる。
-- 緑の場合、対象の対戦相手のパワー12000以上のシグニ１体をバニッシュする。
-- 黒の場合、あなたのトラッシュから対象のシグニ１枚を手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ENA,0,nil)
    if chk==0 then return g:GetCount()>=2 end
    local d=Duel.SelectCards(tp,g,2,g:GetCount())
    local m=0
    for x in d:Iter() do m=m|x:GetColor() end
    e:SetLabel(m)
    Duel.SendToTrash(d,REASON_COST)
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&COLOR_WHITE~=0 then local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.SendToHand(tc) end end
    if m&COLOR_RED~=0 then local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=12000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Banish(tc) end end
    if m&COLOR_BLUE~=0 then Duel.Draw(tp,2) aux.Discard(tp,1) end
    if m&COLOR_GREEN~=0 then local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Banish(tc) end end
    if m&COLOR_BLACK~=0 then local x=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst() if x then Duel.SendToHand(x) end end
  end)
  c:RegisterEffect(e1)
end
