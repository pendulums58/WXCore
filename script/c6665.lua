-- WXK06-050 幻竜　ラプトル
-- 【自】《ターン１回》：このシグニが対戦相手のライフクロス１枚をクラッシュしたとき、《黒》を支払ってもよい。そうした場合、あなたのデッキの上から＜龍獣＞のシグニが３枚トラッシュに置かれるまでカードをトラッシュに置く。その後、この方法で＜龍獣＞のシグニを３枚トラッシュに置いた場合、あなたのトラッシュからレベル３以下の＜龍獣＞のシグニ１枚を対象とし、それを手札に加える。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetCrusher()==e:GetHandler() end)
  e1:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{B}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{B}"),REASON_COST)
    local seen,k=Group.CreateGroup(),0
    local total=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):GetCount()
    for i=1,total do
      local last=nil
      for y in Duel.GetDecktopGroup(tp,i):Iter() do last=y end
      seen:AddCard(last)
      if last:IsSigni() and last:IsClass(0,RACE_RYUJU) then k=k+1 if k>=3 then break end end
    end
    if seen:GetCount()>0 then Duel.SendToTrash(seen,REASON_EFFECT) end
    if k<3 then return end
    local tc=Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_RYUJU) end)(x) and x:GetLevel()<=3 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
