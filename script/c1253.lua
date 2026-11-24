-- WD14-012 毒蛇の華　アシュタルス
-- 【自】：このシグニがバニッシュされたとき、エナゾーンからこのシグニを場に出してもよい。
-- 【出】：あなたは手札を１枚捨てる。この方法で手札を１枚捨てなかった場合、このシグニを場からトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- 에나가 아닌 곳으로 갔으면 낼 수 없다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_ENA) then Duel.PutOnField(h,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()>0 then
      aux.Discard(tp,1)
    elseif h:IsLocation(LOCATION_SZONE) then
      Duel.SendToTrash(h,REASON_EFFECT)
    end
  end)
  c:RegisterEffect(e2)
end
