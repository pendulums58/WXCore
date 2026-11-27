-- WX13-001 真・遊月・伍
-- 【常】：このルリグにグロウする際、あなたのライフクロスが１枚以下の場合、このルリグにグロウするためのコストは《赤×0》《緑×0》になる。
-- 【出】《赤》：対戦相手のエナゾーンからカードを２枚まで対象とし、それらをトラッシュに置く。
-- 【出】《緑》：あなたのデッキの一番上からカードをライフクロスに加える。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》エクシード５：あなたのエナゾーンからすべてのカードをトラッシュに置き、あなたは手札をすべて捨てる。対戦相手のすべてのシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 라이프 1장 이하면 그로우 코스트 0
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetMinCost(function(e,tp,base) return Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=1 and "" or base end)
  e0:SetDeclare(function(e,tp) if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=1 then Duel.SetUseCost("") end end)
  c:RegisterEffect(e0)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{R}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_ENA,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{G}")
  e2:SetOperation(function(e,tp)
    local d=Duel.GetDecktopGroup(tp,1)
    if d:GetCount()>0 then Duel.SendToLife(d) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_LRIG)
  e3:SetExceedCost(5)
  e3:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ENA,0,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if h:GetCount()>0 then Duel.SendToTrash(h,REASON_EFFECT+REASON_DISCARD) end
    local o=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if o:GetCount()>0 then Duel.Banish(o) end
  end)
  c:RegisterEffect(e3)
end
