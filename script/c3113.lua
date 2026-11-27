-- WX20-015 アイヤイ★フォール
-- 【自】：このルリグがアタックしたとき、あなたの場に緑と黒のシグニがある場合、カードを１枚引き、手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local has=function(col) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(col) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 end
    if has(COLOR_GREEN) and has(COLOR_BLACK) then Duel.Draw(tp,1) aux.Discard(tp,1) end
  end)
  c:RegisterEffect(e1)
end
