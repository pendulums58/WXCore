-- WX05-073 咆哮
-- 以下の２つから２つまで選ぶ。
-- ①ターン終了時まで、あなたのすべてのシグニのパワーを＋2000する。
-- ②あなたのセンタールリグがレベル４以上で緑の場合、ターン終了時まで、あなたのすべてのシグニのパワーを＋5000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  -- [まで] 처리할 때 장에 있는 시그니만
  e1:SetOperation(function(e,tp)
    local m,v=e:GetLabel(),0
    if m&1~=0 then v=v+2000 end
    if m&2~=0 and (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:GetLevel()>=4 and lc:IsColor(COLOR_GREEN) end)() then v=v+5000 end
    if v==0 then return end
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,tc,v) end
  end)
  c:RegisterEffect(e1)
end
