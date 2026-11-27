-- WX22-033 コードアンチ　オイニッチ
-- 【出】：あなたのデッキの上からカードを３枚トラッシュに置く。その後、あなたのトラッシュに＜古代兵器＞のシグニが７種類以上ある場合、あなたのトラッシュからレベル４の＜古代兵器＞のシグニ１枚を対象とし、それを手札に加える。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    if (function() local seen,n={},0 for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KODAIHEIKI)) end,tp,LOCATION_TRASH,0,nil):Iter() do if not seen[x:GetCode()] then seen[x:GetCode()]=true n=n+1 end end return n end)()<7 then return end
    local x=Duel.SelectTarget(tp,function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KODAIHEIKI)) end)(c) and c:GetLevel()==4 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if x then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
