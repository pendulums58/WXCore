-- WX20-041-CB ３－遊　§ハッカドール３号§
-- 【出】：あなたのデッキの上から青ではない＜遊具＞のシグニがめくれるまで公開し、そのシグニを手札に加える。残りをシャッフルしてデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local hit,seen=nil,Group.CreateGroup()
    local n=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):GetCount()
    for i=1,n do
      local last=nil
      for y in Duel.GetDecktopGroup(tp,i):Iter() do last=y end
      seen:AddCard(last)
      if (function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end)(x) and not x:IsColor(COLOR_BLUE) end)(last) then hit=last break end
    end
    if seen:GetCount()>0 then Duel.RevealCards(seen) end
    if hit then Duel.SendToHand(hit) end
    local rest=seen:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e1)
end
