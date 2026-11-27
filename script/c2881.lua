-- WX16-066 ＢＡＤ　ＳＩＤＥ
-- 対戦相手の手札を見て無色ではないシグニを１枚選び、捨てさせる。
-- 《トラップアイコン》：対戦相手のレベル２以下のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：対戦相手のレベル２以下のシグニ１体を対象とし、それをデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g:Filter(function(c) return c:IsSigni() and c:GetColor()~=0 end,nil),1,1)
    if x:GetCount()>0 then Duel.SendToTrash(x,REASON_EFFECT+REASON_DISCARD) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_TRAP)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=2 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=2 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckPosition(tc,1) end
  end)
  c:RegisterEffect(e3)
end
