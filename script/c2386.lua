-- WX10-007 祈願の使者　サシェ・モティエ
-- 【出】：あなたのデッキの一番上を見る。それがレベル３以下の＜宇宙＞のシグニの場合、それを場に出してもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.ConfirmCards(tp,x)
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_UCHU)) end)(x) and x:GetLevel()<=3 and Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e1)
end
