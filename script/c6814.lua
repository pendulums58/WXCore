-- WXK08-027 炎魔の総統　アミィ
-- 【出】：対戦相手のパワー8000以下のシグニ１体を対象とし、あなたの場にそれぞれレベルの異なるシグニが３体ある場合、それをバニッシュする。
-- 【起】《ターン１回》手札を１枚捨て、他のシグニ１体を場からトラッシュに置き、エナゾーンからカード１枚をトラッシュに置く：あなたのデッキの上からカードを４枚公開する。その中からそれぞれレベルの異なるシグニを４枚まで手札に加え、残りをトラッシュに置く。
-- ライフバースト：対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=8000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
      if g:GetCount()==3 and aux.DistinctLevels(g) then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    local s=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x~=e:GetHandler() end,tp,LOCATION_SZONE,0,nil)
    local en=Duel.GetMatchingGroup(nil,tp,LOCATION_ENA,0,nil)
    if chk==0 then return h:GetCount()>0 and s:GetCount()>0 and en:GetCount()>0 end
    Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_COST+REASON_DISCARD)
    Duel.SendToTrash(Duel.SelectCards(tp,s,1,1),REASON_COST)
    Duel.SendToTrash(Duel.SelectCards(tp,en,1,1),REASON_COST)
  end)
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local s=g:Filter(Card.IsSigni,nil)
    Duel.SetSelectCheck(aux.DistinctLevels)
    local pick=s:GetCount()>0 and Duel.SelectCards(tp,s,0,4) or Group.CreateGroup()
    if pick:GetCount()>0 then Duel.SendToHand(pick) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=10000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.Banish(tc)
    end
  end)
  c:RegisterEffect(e9)
end
