-- WD21-013 羅星　≡ガイテン≡
-- 【起】《ダウン》：あなたの＜宇宙＞のシグニ２体を場からトラッシュに置く。そうした場合、あなたのデッキからレベル４のシグニ１枚を探して場に出し、デッキをシャッフルする。
-- ライフバースト：あなたのデッキから＜宇宙＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
s.uchu=aux.ClassFilter(0,RACE_UCHU)  -- ＜宇宙＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  -- 자신도 놓을 수 있다(FAQ 1). 레벨·리미트를 넘는 시그니는 내지 못한다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(s.uchu,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()<2 or Duel.SendToTrash(Duel.SelectCards(tp,g,2,2),REASON_EFFECT)<2 then return end
    local tc=aux.Search(tp,function(x) return x:IsSigni() and x:IsLevelBetween(4,4) end,1):GetFirst()
    if tc then Duel.PutOnField(tc,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) aux.SearchToHand(tp,s.uchu,1) end)
  c:RegisterEffect(e2)
end
