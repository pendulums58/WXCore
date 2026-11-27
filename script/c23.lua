-- WX09-Re03 ゼノ・マルチプル
-- 以下の４つから２つまで選ぶ。
-- ①対戦相手のセンタールリグ１体を対象する。このターン、プレイヤーはそれでアタックできない。
-- ②対戦相手のすべてのシグニを凍結する。
-- ③対戦相手のシグニ１体を対象とし、それを手札に戻す。
-- ④カードを２枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    s.l=m&1~=0 and Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil):GetFirst() or nil
    s.b=m&4~=0 and Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    -- [まで] このターン
    if s.l and s.l:IsRelateToEffect(e) then aux.GrantKeyword(e,s.l,EFFECT_CANNOT_ATTACK) end
    if m&2~=0 then Duel.Freeze(Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)) end
    if s.b and s.b:IsRelateToEffect(e) then Duel.SendToHand(s.b) end
    if m&8~=0 then Duel.Draw(tp,2) end
  end)
  c:RegisterEffect(e1)
end
