-- WDK13-013 羅星 ハッブラ
-- 【出】手札から＜宇宙＞のシグニを１枚捨てる：あなたのデッキからこの方法で捨てたシグニよりレベルが１つ高いシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
s.space=aux.ClassFilter(0,RACE_UCHU)  -- ＜宇宙＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetMatchingGroup(s.space,tp,LOCATION_HAND,0,nil):GetCount()>0 end
    local g=Duel.SelectDiscard(tp,1,1,s.space)
    e:SetLabel(g:GetFirst():GetLevel())
    Duel.SendToTrash(g,REASON_COST+REASON_DISCARD)
  end)
  e1:SetOperation(function(e,tp)
    local g=aux.Search(tp,function(x) return x:IsSigni() and x:GetLevel()==e:GetLabel()+1 end,1)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
