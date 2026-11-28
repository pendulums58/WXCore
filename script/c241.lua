-- PR-380 ステアード・サルベージ（「selector stirred WIXOSS」単行本 付録）
-- あなたのルリグトラッシュから、このアーツの使用コストで支払ったエナと共通する色を持つ、アーツとレゾナをそれぞれ１枚まで対象とし、それらをルリグデッキに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 낸 엔의 색은 사용할 때 고른 색으로 근사(《白》 또는 《黒》)
  e1:SetOperation(function(e,tp)
    local col=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 and COLOR_WHITE or COLOR_BLACK
    local g=Group.CreateGroup()
    for _,t in ipairs({TYPE_ARTS,TYPE_RESONA}) do
      local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(c) return c:IsType(t) and c:IsColor(col) end,tp,LOCATION_LTRASH,0,nil),0,1)
      g:Merge(x)
    end
    if g:GetCount()>0 then Duel.SendToLrigDeck(g) end
  end)
  c:RegisterEffect(e1)
end
