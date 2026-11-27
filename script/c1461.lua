-- WX21-065 幻竜　＃プロケラ#
-- 【出】：あなたの手札から名前の異なる＜龍獣＞のシグニを２枚まで公開してもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,tp,LOCATION_HAND,0,nil)
    Duel.SetSelectCheck(function(sg) local seen={} for x in sg:Iter() do if seen[x:GetCode()] then return false end seen[x:GetCode()]=true end return true end)
    local r=Duel.SelectCards(tp,g,0,2)
    if r:GetCount()>0 then Duel.RevealCards(r) end
  end)
  c:RegisterEffect(e1)
end
