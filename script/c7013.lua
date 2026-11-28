-- WXK10-039 羅原　ＣＨ４
-- 【常】：【アサシン】
-- 【出】：あなたの他の＜原子＞のシグニ２体を場からトラッシュに置かないかぎり、このシグニを場からトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ASSASSIN)
  e1:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_GENSHI) end)(x) and x~=h end,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()>=2 and Duel.SelectYesNo(tp) then Duel.SendToTrash(Duel.SelectCards(tp,g,2,2),REASON_EFFECT) return end
    if h:IsLocation(LOCATION_SZONE) then Duel.SendToTrash(h,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
