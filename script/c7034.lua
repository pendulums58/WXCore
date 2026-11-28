-- WXK10-060 羅植　ユキヤナギ
-- 【常】：このシグニと同じシグニゾーンに【シード】があるかぎり、このシグニのパワーは＋3000される。
-- 【出】：あなたのデッキの上からカードを３枚公開する。この方法で＜植物＞のシグニが３種類公開された場合、その中から１枚をエナゾーンに置く。残りをシャッフルしてデッキの一番下に置く。（２種類以下の場合もシャッフルして下に置く）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local h=e:GetHandler() return Duel.GetMatchingGroup(function(x) return x:GetZone()==h:GetZone() end,h:GetControler(),LOCATION_SEED,0,nil):GetCount()>0 end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local seen,n={},0
    for x in g:Iter() do if x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) and not seen[x:GetCode()] then seen[x:GetCode()]=true n=n+1 end end
    if n>=3 then Duel.SendToEna(Duel.SelectCards(tp,g,1,1)) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e2)
end
