-- WX16-044 コードイート　ダイフク
-- 【常】：このシグニにアクセするための、エナゾーンにあるシグニの【起】能力の使用コストは《緑×1》減る。
-- 【常】：このシグニはアクセされているかぎり、バニッシュされない。
-- 【自】：各ターン終了時、このシグニに付いている【アクセ】１枚を対象とし、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 아크세 코스트 감소는 아직(근사 없음)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_CANNOT_BANISH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsAcce() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_TURN_END)
  e2:SetRange(LOCATION_SZONE)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(x) return x:GetAcceHost()==h end,tp,LOCATION_ACCE,0,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
