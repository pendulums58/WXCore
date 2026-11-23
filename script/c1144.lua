-- WD06-010 幻水　オクト
-- 【常】：あなたの場に他の＜水獣＞のシグニがあるかぎり、このシグニの基本パワーは12000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 다른 ＜水獣＞가 있는 동안. 기본 파워라 다른 ±는 그 위에
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_SET_BASE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e)
    local h=e:GetHandler()
    return Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_SUIJU),e:GetHandlerPlayer(),LOCATION_SIGNI,0,h):GetCount()>0
  end)
  e1:SetValue(12000)
  c:RegisterEffect(e1)
end
