-- WDK16-12 コードＶＬ　モイラ
-- 【出】：あなたの登録者数が８０万人を達成している場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    if Duel.GetSubscribers(tp)>=80 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
