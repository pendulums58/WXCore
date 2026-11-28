-- WXK03-040 紋英の採取　シモン
-- 【出】：あなたのターンの場合、あなたのデッキの一番下のカードをトラッシュに置く。それがレベル１のシグニの場合、それをトラッシュから場に出す。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    if Duel.GetTurnPlayer()~=tp then return end
    local x=Duel.GetDeckbottomGroup(tp,1):GetFirst()
    if not x then return end
    Duel.SendToTrash(x,REASON_EFFECT)
    if x:IsLocation(LOCATION_TRASH) and x:IsSigni() and x:GetLevel()==1 then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
