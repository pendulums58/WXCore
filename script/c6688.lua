-- WXK06-073 コードメイズ　ジョジア
-- 【出】：対戦相手の手札を見て無色ではないカードを１枚まで選ぶ。カードを１枚選んだ場合、対戦相手はそれをデッキの一番下に置きカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if h:GetCount()==0 then return end
    Duel.ConfirmCards(tp,h)
    local x=Duel.SelectCards(tp,h:Filter(function(y) return y:GetColor()~=0 end,nil),0,1)
    if x:GetCount()>0 then Duel.SendToDeckBottom(x,false) Duel.Draw(1-tp,1) end
  end)
  c:RegisterEffect(e1)
end
