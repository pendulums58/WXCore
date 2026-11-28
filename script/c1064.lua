-- WDK16-10 ファイト・ゴースト
-- あなたのデッキから＜電機＞のシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。登録者数を２０万人得る。あなたのセンタールリグのレベルが対戦相手のセンタールリグと同じ場合、追加で登録者数を１０万人得る。
local s,id=GetID()
s.denki=aux.ClassFilter(0,RACE_DENKI)  -- ＜電機＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=aux.Search(tp,s.denki,2)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
    Duel.AddSubscribers(tp,20)
    local a=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local b=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
    if a and b and a:GetLevel()==b:GetLevel() then Duel.AddSubscribers(tp,10) end
  end)
  c:RegisterEffect(e1)
end
