-- WD23-034-A 大罠　スライチェア
-- 【トラップアイコン】：あなたのデッキの上からカードを２枚見る。その中からカード１枚を【トラップ】としてあなたのシグニゾーンに設置し、残りを手札に加える。
-- ライフバースト：あなたのデッキの一番上を見る。そのカードを手札に加えるか、【トラップ】としてあなたのシグニゾーンに設置する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_TRAP)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local tc=Duel.SelectCards(tp,g,1,1):GetFirst()
    if tc then Duel.SetTrap(tc,tp) end
    local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToHand(rest) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not tc then return end
    Duel.ConfirmCards(tp,tc)
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.SendToHand(tc) else Duel.SetTrap(tc,tp) end
  end)
  c:RegisterEffect(e2)
end
