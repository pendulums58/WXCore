-- WX17-038 羅星　≡タイトツ≡
-- 【常】：このシグニは中央のシグニゾーンにあるかぎり、「【自】：このシグニがアタックしたとき、あなたのデッキの上から＜宇宙＞のシグニがめくれるまで公開する。その後、この方法で公開した＜宇宙＞のシグニと同じレベルの対戦相手のシグニ１体を対象とし、それをバニッシュする。公開したカードをシャッフルしてデッキの一番下に置く。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 중앙에 있는 동안 얻는다
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetCode(EVENT_ATTACK)
  g:SetOperation(function(e,tp)
    local hit,seen=nil,Group.CreateGroup()
    for x in Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):Iter() do end
    local deck=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):GetCount()
    for i=1,deck do
      local x=Duel.GetDecktopGroup(tp,i):GetFirst()
      local g=Duel.GetDecktopGroup(tp,i)
      local last=nil
      for y in g:Iter() do last=y end
      seen:AddCard(last)
      if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_UCHU)) end)(last) then hit=last break end
    end
    if seen:GetCount()>0 then Duel.RevealCards(seen) end
    if hit then
      local lv=hit:GetLevel()
      local tc=Duel.SelectTarget(tp,function(c) return c:IsSigni() and c:GetLevel()==lv end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    end
    local rest=seen:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsInZone("signi_center") end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
end
