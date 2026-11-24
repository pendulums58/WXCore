-- WDK10-013 幻竜　キュリア
-- 【常】：あなたのトラッシュに＜龍獣＞のシグニが５枚以上あるかぎり、このシグニのパワーは＋4000される。
-- 【自】：このシグニがアタックしたとき、あなたのトラッシュに＜龍獣＞のシグニが１０枚以上ある場合、対戦相手のデッキの上からカードを４枚トラッシュに置く。
local s,id=GetID()
s.ryu=aux.ClassFilter(0,RACE_RYUJU)  -- ＜龍獣＞のシグニ
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(s.ryu,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=5 end)
  e1:SetValue(4000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(s.ryu,tp,LOCATION_TRASH,0,nil):GetCount()<10 then return end
    local g=Duel.GetDecktopGroup(1-tp,4)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
