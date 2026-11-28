-- WXK05-051 羅植　コデマリ
-- 【自】《ターン１回》：このシグニがアタックしたとき、あなたのデッキの上からカードを３枚公開する。それらがそれぞれ名前の異なる＜植物＞のシグニの場合、このシグニをアップする。公開したカードをシャッフルしてデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCountLimit(1)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local ok=g:GetCount()==3
    local s={}
    for x in g:Iter() do if not ((function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end)(x)) or s[x:GetCode()] then ok=false else s[x:GetCode()]=true end end
    local h=e:GetHandler()
    if ok and h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
    Duel.SendToDeckBottom(g,true)
  end)
  c:RegisterEffect(e1)
end
