-- WX04-015 マインド・マインズ
-- 対戦相手は、自分のデッキを上からスペルがめくれるまで公開する。その後、公開されたスペルをチェックゾーンに置き、残りをデッキに戻してシャッフルする。あなたは、そのスペルをあなたの手札にあるかのようにコストを支払わずに限定条件を無視して使用してもよい。使用しなかった場合、そのスペルを対戦相手のトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 한정 조건만 무시한다. 「…場合にしか使用できない」는 지킨다(FAQ 1·8)
  e1:SetOperation(function(e,tp)
    local n,g,sp=0,nil,nil
    repeat
      n=n+1
      g=Duel.GetDecktopGroup(1-tp,n)
      sp=g:Filter(function(x) return x:IsType(TYPE_SPELL) end,nil):GetFirst()
    until sp or g:GetCount()<n
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local rest=g:Filter(function(x) return x~=sp end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckShuffle(rest,1-tp) else aux.ShuffleDeck(1-tp) end
    if not sp then return end
    if not (Duel.SelectYesNo(tp) and Duel.UseFree(sp,tp)) then Duel.SendToTrash(sp,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
