-- WX05-030 ゲット・グリモア
-- 手札から＜アーム＞のシグニ１枚を公開する。あなたのデッキからこの方法で公開したシグニと同じ名前のシグニを３枚まで探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：手札から＜アーム＞のシグニを１枚捨てる。そうした場合、あなたのデッキから＜アーム＞のシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- 패는 비공개라 공개하지 않아도 된다
    local x=aux.RevealFromHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end,1):GetFirst()
    if not x then
      aux.ShuffleDeck(tp)
      return
    end
    aux.SearchToHand(tp,function(c) return c:IsSigni() and c:IsCardName(x:GetCode()) end,3)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local g=Duel.SelectDiscard(tp,0,1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end)
    if g:GetCount()==0 or Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD)==0 then return end
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end,2)
  end)
  c:RegisterEffect(e2)
end
