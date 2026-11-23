-- WDK08-Y07 真空斬撃
-- ベット―《コインアイコン》
-- 手札からシグニ１枚を公開する。その後、この方法で公開されたシグニのパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- あなたがベットしていた場合、代わりにこの方法で公開されたシグニのパワー以下の対戦相手のシグニ１体を対象とし、それをエナゾーンに置き、【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 공개하지 않아도 된다. 그러면 파워 0 이하만 대상(FAQ 3). 대상은 공개한 뒤에 고른다(「その後」)
function s.op(e,tp)
  local r=Duel.SelectCards(tp,Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_HAND,0,nil),0,1)
  local pw=0
  if r:GetCount()>0 then
    pw=r:GetFirst():GetPower()
    Duel.RevealCards(r)
  end
  local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=pw end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
  if Duel.IsBet() then
    -- 바니시가 아니라 에나 존에 놓는다(「バニッシュされない」도. FAQ 2)
    if tc then Duel.SendToEna(tc) end
    Duel.EnaCharge(tp,1)
  elseif tc then
    Duel.Banish(tc)
  end
end
