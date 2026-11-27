-- WX05-066 ＲＡＩＮＹ
-- 以下の２つから２つまで選ぶ。
-- ①対戦相手は手札を１枚捨てる。
-- ②あなたのセンタールリグがレベル４以上で青の場合、カードを３枚引き、手札を１枚捨てる。
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
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then aux.Discard(1-tp,1) end
    if m&2~=0 and (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:GetLevel()>=4 and lc:IsColor(COLOR_BLUE) end)() then
      Duel.Draw(tp,3)
      aux.Discard(tp,1)
    end
  end)
  c:RegisterEffect(e1)
end
