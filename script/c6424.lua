-- WXK03-050 仁の遊　ツミキ
-- 【出】《白》：あなたのターンの場合、あなたのデッキの一番上を公開する。それがレベル２以下の＜遊具＞のシグニの場合、それを場に出す。そうでない場合、それをデッキの一番下に置いてもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{W}")
  e1:SetOperation(function(e,tp,eg)
    if Duel.GetTurnPlayer()~=tp then return end
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if x:IsSigni() and x:IsClass(0,RACE_YUGU) and x:GetLevel()<=2 and Duel.PutOnField(x,tp) then return end
    if x:IsLocation(LOCATION_MDECK) and Duel.SelectYesNo(tp) then Duel.SendToDeckBottom(x,false) end
  end)
  c:RegisterEffect(e1)
end
