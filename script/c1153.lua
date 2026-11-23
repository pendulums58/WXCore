-- WD07-003 ハーフ/メイデン　イオナ
-- 【常】：対戦相手のシグニは可能ならばアタックしなければならない。
-- 【常】：あなたの場に白と黒のシグニがあるかぎり、あなたのシグニのパワーを＋1000する。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_MUST_ATTACK)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(0,LOCATION_SIGNI)
  c:RegisterEffect(e1)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_LRIG)
  e2:SetTargetRange(LOCATION_SIGNI,0)
  e2:SetCondition(function(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end,tp,LOCATION_SIGNI,0,nil):GetCount()>0
       and Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_SIGNI,0,nil):GetCount()>0
  end)
  e2:SetValue(1000)
  c:RegisterEffect(e2)
end
