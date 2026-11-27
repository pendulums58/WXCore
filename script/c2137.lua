-- WX06-013 後悔の公開　アン＝サード
-- 【出】：あなたのデッキの上からカードを２枚公開する。その中から＜美巧＞のシグニ１枚を手札に加える。残りを好きな順番でデッキの一番上か一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,2))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local pick=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,nil),0,1)
    if pick:GetCount()>0 then Duel.SendToHand(pick) end
    local rest=g:Filter(function(x) return not pick:IsContains(x) end,nil)
    if rest:GetCount()==0 then return end
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then
      aux.ToDeckTopInOrder(tp,rest)
    else
      Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false)
    end
  end)
  c:RegisterEffect(e1)
end
