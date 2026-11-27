-- WX20-060 幻竜　シルシュ
-- 【自】：このシグニがアタックしたとき、あなたのデッキの上からカードを２枚公開する。その中から＜龍獣＞のシグニ１枚を手札に加え、残りをトラッシュに置く。
-- 【出】：対戦相手のエナゾーンからカードを２枚まで対象とし、あなたのトラッシュにカード名に《ムシュフシュ》を含むカードがある場合、それらをトラッシュに置く。その後、この方法でトラッシュに置かれたカード１枚につき対戦相手はデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,2))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local x=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,nil),0,1)
    if x:GetCount()>0 then Duel.SendToHand(x) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_ENA,0,2,nil)
  end)
  e2:SetOperation(function(e,tp)
    if not (Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"ムシュフシュ") end,tp,LOCATION_TRASH,0,nil):GetCount()>0) then return end
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    local n=g:GetCount()>0 and Duel.SendToTrash(g,REASON_EFFECT) or 0
    if n>0 then Duel.EnaCharge(1-tp,n) end
  end)
  c:RegisterEffect(e2)
end
