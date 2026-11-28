-- SP27-005 幻水　アユ（セレクターズパック vol.16）
-- 【自】：このシグニがバニッシュされたとき、《青》を支払ってもよい。そうした場合、あなたのデッキの上から＜水獣＞のシグニがめくれるまで公開し、そのシグニを手札に加えるか場に出す。残りをシャッフルしてデッキの一番下に置く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  -- 에나에 간 이 카드로도 낼 수 있다(FAQ 1). 낼 수 없는 레벨이면 패에(FAQ 3)
  e1:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
    local seen=Group.CreateGroup()
    local hit=nil
    local n=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):GetCount()
    for i=1,n do
      local last=nil
      for y in Duel.GetDecktopGroup(tp,i):Iter() do last=y end
      seen:AddCard(last)
      if last:IsSigni() and last:IsClass(0,RACE_SUIJU) then hit=last break end
    end
    if seen:GetCount()==0 then return end
    Duel.RevealCards(seen)
    if hit then
      if not (Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==1 and Duel.PutOnField(hit,tp)) then Duel.SendToHand(hit) end
    end
    local rest=seen:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
