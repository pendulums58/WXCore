-- WXK08-029 炎翼の翔破
-- あなたのトラッシュから＜悪魔＞のシグニ１枚を対象とし、あなたの【ビート】が４枚以下の場合、それを【ビート】にする。この方法であなたの【ビート】が４枚になった場合、カードを２枚引く。
-- ライフバースト：あなたのトラッシュから＜悪魔＞のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_AKUMA) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if Duel.GetMatchingGroup(nil,tp,LOCATION_BEAT,0,nil):GetCount()<=4 and Duel.Beat(tc)>0 and Duel.GetMatchingGroup(nil,tp,LOCATION_BEAT,0,nil):GetCount()==4 then Duel.Draw(tp,2) end
    end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_AKUMA) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e9)
end
