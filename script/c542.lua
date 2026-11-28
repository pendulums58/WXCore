-- WXK01-005 インサイダー・サルベージ
-- あなたのトラッシュからシグニ１枚を対象とし、それを手札に加える。この方法で黒のシグニを手札に加えた場合、このカードをルリグデッキに戻し、このターン、あなたは《インサイダー・サルベージ》を使用できない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local black=tc:IsColor(COLOR_BLACK)
    if Duel.SendToHand(tc)==0 or not black then return end
    local me=e:GetHandler()
    if me:IsLocation(LOCATION_CHECK) then Duel.SendToLrigDeck(me) end
    -- [の間] 「このターン」
    local e1=Effect.CreateEffect(me)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_USE)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e2,x) return x:IsCardName(id) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
