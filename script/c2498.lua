-- WX11-049 幻蟲　キイロテン
-- 【出】：対戦相手の場にあるすべての【チャーム】をトラッシュに置く。
-- 【起】《アタックフェイズアイコン》《黒×0》：このシグニをトラッシュから場に出す。この能力は対戦相手の場に【チャーム】が３枚ある場合にしか使用できない。（この能力は、このシグニがトラッシュにある場合にしか使用できない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetCharm()~=nil end,tp,0,LOCATION_SZONE,nil):Iter() do Duel.SendToTrash(x:GetCharm(),REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_TRASH)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCondition(function(e,tp) return (function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do if x:GetCharm() then n=n+1 end end return n end)(1-tp)>=3 end)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) then Duel.PutOnField(h,tp) end
  end)
  c:RegisterEffect(e2)
end
