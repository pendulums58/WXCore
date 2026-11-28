-- WXK07-054-CB 羅星 人生さんB
-- 【常】：あなたの場に《羅星 人生さんＲ》があるかぎり、このシグニのパワーは＋4000される。
-- 【自】：このシグニがアタックしたとき、《黒》を支払ってもよい。そうした場合、あなたのデッキを上から公開されたシグニのレベルの合計が５以上になるまで公開する。その後、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを、この方法で公開されたシグニ１枚につき－1000する。公開したカードをシャッフルしてデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsCardName(6753) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  e1:SetValue(4000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{B}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{B}"),REASON_COST)
    local seen=Group.CreateGroup()
    local total=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):GetCount()
    for i=1,total do
      if not ((function() local n=0 for y in seen:Iter() do if y:IsSigni() then n=n+y:GetLevel() end end return n end)()<5) then break end
      local last=nil
      for y in Duel.GetDecktopGroup(tp,i):Iter() do last=y end
      seen:AddCard(last)
    end
    if seen:GetCount()>0 then Duel.RevealCards(seen) end
    local k=(function() local n=0 for y in seen:Iter() do if (Card.IsSigni)(y) then n=n+1 end end return n end)()
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc and k>0 then aux.AddPower(e,tc,-1000*k) end
    local rest=seen:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e2)
end
