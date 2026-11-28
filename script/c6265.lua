-- WXK01-084 魔海の吸盤　オクトパス
-- 【自】：あなたのターン終了時、あなたの手札が１枚以下でこのシグニが中央のシグニゾーンにある場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp,eg)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()<=1 and e:GetHandler():IsInZone("signi_center") then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
