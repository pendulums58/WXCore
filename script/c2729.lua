-- WX14-069 華歌
-- あなたのデッキの上からカードを２枚エナゾーンに置く。この方法で＜植物＞のシグニが２枚エナゾーンに置かれた場合、追加であなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.SendToEna(g)
    if g:Filter(function(x) return x:IsLocation(LOCATION_ENA) and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_SHOKUBUTSU)) end)(x) end,nil):GetCount()>=2 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
end
