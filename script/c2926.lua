-- WX17-039 羅星　≡コズトリン≡
-- 【起】《ダウン》：３以外の数字１つを宣言する。あなたのデッキの上から宣言した数字と同じレベルを持つ＜宇宙＞のシグニがめくれるまで公開し、それを手札に加える。公開した他のカードをシャッフルしてデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp)
    local nums={}
    for _,v in ipairs({0,1,2,4,5}) do nums[#nums+1]=v end
    local n=Duel.AnnounceNumber(tp,0,5)
    if n==3 then n=4 end  -- 3은 고를 수 없다
    local hit,seen=nil,Group.CreateGroup()
    for x in Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):Iter() do end
    local deck=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):GetCount()
    for i=1,deck do
      local x=Duel.GetDecktopGroup(tp,i):GetFirst()
      local g=Duel.GetDecktopGroup(tp,i)
      local last=nil
      for y in g:Iter() do last=y end
      seen:AddCard(last)
      if (function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_UCHU)) end)(c) and c:GetLevel()==n end)(last) then hit=last break end
    end
    if seen:GetCount()>0 then Duel.RevealCards(seen) end
    if hit then Duel.SendToHand(hit) end
    local rest=seen:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e1)
end
