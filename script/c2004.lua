-- WX04-007 十六夜の巫女　タマヨリヒメ
-- 【出】《無》：あなたのデッキから白のスペル１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{C}")
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsType(TYPE_SPELL) and x:IsColor(COLOR_WHITE) end,1)
  end)
  c:RegisterEffect(e1)
end
