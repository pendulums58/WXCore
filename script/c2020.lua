-- WX04-041 コードメイズ　スカイジュ
-- 【常】：あなたの場に他の＜迷宮＞のシグニがあるかぎり、このシグニの基本パワーは10000になる。
-- 【出】：対戦相手のすべてのシグニを好きなように配置し直してもよい。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePowerWhileClass(c,RACE_MEIKYU,10000)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    if Duel.SelectYesNo(tp) then s.rearrange(tp,1-tp) end
  end)
  c:RegisterEffect(e1)
end
-- 시그니를 하나 골라 다른 존으로(차 있으면 맞바꾼다). 그만둘 때까지
function s.rearrange(tp,p)
  for _=1,6 do
    local c=Duel.SelectCards(tp,Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SIGNI,0,nil),0,1):GetFirst()
    if not c then return end
    local zones={}
    for _,z in ipairs(Duel.GetSigniZones(p)) do if z~=c:GetZone() then zones[#zones+1]=z end end
    local z=Duel.SelectZone(tp,zones)
    if not z then return end
    local o=Duel.GetMatchingGroup(function(x) return x:GetZone()==z end,p,LOCATION_SIGNI,0,nil):GetFirst()
    Duel.SwapSigni(c,o or z)
  end
end
