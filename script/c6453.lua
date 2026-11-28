-- WXK03-079 大罠　ダイイング・M
-- 【出】：あなたのターンの場合、あなたのデッキの一番上のカードをトラッシュに置く。それがレベルが奇数の＜トリック＞のシグニの場合、それをトラッシュから場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    if Duel.GetTurnPlayer()~=tp then return end
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    if x:IsLocation(LOCATION_TRASH) and x:IsSigni() and x:IsClass(0,RACE_TRICK) and x:GetLevel()%2==1 then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e1)
end
