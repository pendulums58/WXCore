-- WX09-041 ゲット・ブリリアント
-- あなたのデッキから白のシグニ１枚を探して公開し手札に加える。あなたの場に白のシグニが３体あり、それらが共通するクラスを持つ場合、追加で白のシグニ１枚を探して公開し手札に加える。その後、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local n=(function() local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end,tp,LOCATION_SZONE,0,nil) return g:GetCount()==3 and aux.ShareClass(g) end)() and 2 or 1
    local g=aux.Search(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end,n)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
