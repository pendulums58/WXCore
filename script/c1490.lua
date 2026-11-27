-- WX18-028 ディプレス・スケール
-- シグニのカード名１つを宣言する。あなたのデッキの上から宣言したカードがめくれるまで公開する。その後、そのシグニを場に出し、残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local cid=Duel.AnnounceCard(tp)
    local seen=Group.CreateGroup()
    local hit=nil
    local n=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):GetCount()
    for i=1,n do
      local last=nil
      for y in Duel.GetDecktopGroup(tp,i):Iter() do last=y end
      seen:AddCard(last)
      if last:IsSigni() and last:IsCardName(cid) then hit=last break end
    end
    if seen:GetCount()==0 then return end
    Duel.RevealCards(seen)
    if hit then Duel.PutOnField(hit,tp) end
    local rest=seen:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
