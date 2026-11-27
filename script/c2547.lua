-- WX12-019 弩炎　フレイスロ中将
-- 【出】：あなたのデッキの上からカードを２枚公開する。その中からカード名に《フレイスロ》を含むすべてのカードを手札に加え、残りをトラッシュに置く。
-- 【起】手札からカード名に《フレイスロ》を含むカードを１枚捨てる：パワーが「あなたのトラッシュにあるカード名に《フレイスロ》を含むカードの枚数×2000」以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：あなたのトラッシュからカード名に《フレイスロ》を含むシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,2))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local f=g:Filter(function(x) return aux.NameHas(x,"フレイスロ") end,nil)
    if f:GetCount()>0 then Duel.SendToHand(f) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(aux.DiscardCost(1,function(x) return aux.NameHas(x,"フレイスロ") end))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local n=2000*Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"フレイスロ") end,tp,LOCATION_TRASH,0,nil):GetCount()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=n end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and aux.NameHas(x,"フレイスロ") end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e3)
end
