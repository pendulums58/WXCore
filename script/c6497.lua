-- WXK04-041 ホワイト・ガーデン
-- 以下の２つから１つを選ぶ。
-- ①あなたのデッキから＜植物＞のシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。
-- ②あなたのデッキから＜植物＞のシグニを３枚まで探してエナゾーンに置き、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end,2) return end
    local g=aux.Search(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end,3)
    if g:GetCount()>0 then Duel.SendToEna(g) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
