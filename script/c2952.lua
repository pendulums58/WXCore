-- WX17-071 ＦＡＫＥ　ＤＯＬＬ
-- 対戦相手の＜精元＞のシグニ１体を対象とし、それをデッキの一番上に置く。
-- 【トラップアイコン】：どちらか１つを選ぶ。
-- ①あなたのトラッシュから無色のカード１枚を対象とし、それを手札に加える。
-- ②対戦相手の手札を見て無色のカードを１枚選び、捨てさせる。
-- ライフバースト：どちらか１つを選ぶ。
-- ①あなたのトラッシュから無色のカード１枚を対象とし、それを手札に加える。
-- ②対戦相手の手札を見て無色のカードを１枚選び、捨てさせる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(SYS_SEIGEN,0) end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckPosition(tc,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_TRAP)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e2:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      local x=Duel.SelectTarget(tp,function(x) return x:GetColor()==0 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if x then Duel.SendToHand(x) end
    else
      local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
      if g:GetCount()==0 then return end
      Duel.ConfirmCards(tp,g)
      local x=Duel.SelectCards(tp,g:Filter(function(x) return x:GetColor()==0 end,nil),1,1)
      if x:GetCount()>0 then Duel.SendToTrash(x,REASON_EFFECT+REASON_DISCARD) end
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e3:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      local x=Duel.SelectTarget(tp,function(x) return x:GetColor()==0 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if x then Duel.SendToHand(x) end
    else
      local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
      if g:GetCount()==0 then return end
      Duel.ConfirmCards(tp,g)
      local x=Duel.SelectCards(tp,g:Filter(function(x) return x:GetColor()==0 end,nil),1,1)
      if x:GetCount()>0 then Duel.SendToTrash(x,REASON_EFFECT+REASON_DISCARD) end
    end
  end)
  c:RegisterEffect(e3)
end
