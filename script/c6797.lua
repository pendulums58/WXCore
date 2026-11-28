-- WXK08-008 月ノ美兎　レベル２´
-- 【出】：登録者数を１０万人得る。
-- 【出】：あなたの登録者数が５０万人を達成している場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    Duel.AddSubscribers(tp,10)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    if Duel.GetSubscribers(tp)>=50 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
end
