-- WX04-011 コードピルルク・E
-- 【出】《青》：あなたのルリグデッキから、使用タイミングに《メインフェイズアイコン》を含むコストの合計が３以下の青のアーツ１枚をコストを支払わずに使用する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{U}")
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_ARTS) and x:IsColor(COLOR_BLUE) and x:GetCostTotal()<=3 and x:HasTiming(TIMING_MAIN) end,tp,LOCATION_LDECK,0,nil)
    local a=Duel.SelectCards(tp,g,0,1):GetFirst()
    if a then Duel.UseFree(a,tp) end
  end)
  c:RegisterEffect(e1)
end
