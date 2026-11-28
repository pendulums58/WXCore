-- WXK10-050 コードアート　Ｎ・Ｔ・Ｃ
-- 【自】：このシグニに《改造素材》が使用されたとき、あなたのトラッシュからレベルの異なる＜電機＞のシグニ２枚を対象とし、それらをエナゾーンに置く。
-- 【起】エナゾーンからレベル１～４の＜電機＞のシグニを１枚ずつトラッシュに置く：対戦相手のシグニを、レベルの合計が６以下になるように２体まで対象とし、それらをエナゾーンに置く。
-- ライフバースト：対戦相手のレベル３以上のシグニ１体を対象とし、それをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CUSTOM+6974)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetSelectCheck(aux.DistinctLevels)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end,tp,LOCATION_TRASH,0,2,2,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToEna(g) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return (function(p) for lv=1,4 do if Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) and x:GetLevel()==lv end,p,LOCATION_ENA,0,nil):GetCount()<1 then return false end end return true end)(tp) end
    local g=Group.CreateGroup()
    for lv=1,4 do g:AddCard(Duel.SelectCards(tp,Duel.GetMatchingGroup(function(y) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(y) and y:GetLevel()==lv end,tp,LOCATION_ENA,0,nil),1,1):GetFirst()) end
    Duel.SendToTrash(g,REASON_COST)
  end)
  e2:SetOperation(function(e,tp,eg)
    Duel.SetSelectCheck(function(sg) local n=0 for x in sg:Iter() do n=n+x:GetLevel() end return n<=6 end)
    local g=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
    if g:GetCount()>0 then Duel.SendToEna(g) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()>=3 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToEna(tc)
    end
  end)
  c:RegisterEffect(e9)
end
