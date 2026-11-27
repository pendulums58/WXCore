-- WX11-011 サモン・ラビリンス
-- あなたのデッキからレベル２以下の白のシグニ１枚を探して場に出し、デッキをシャッフルする。あなたのセンタールリグが＜イオナ＞の場合、代わりにレベル４以下の白のシグニ１枚を探して場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local lv=(function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_IONA) end)() and 4 or 2
    local x=aux.Search(tp,function(c) return c:IsSigni() and c:IsColor(COLOR_WHITE) and c:GetLevel()<=lv end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
