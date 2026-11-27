-- WX20-058 羅石　イモイシ
-- 【出】手札から＜鉱石＞のシグニ１枚と＜宝石＞のシグニ１枚を捨てる：カードを３枚引く。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local a=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI)) end,tp,LOCATION_HAND,0,nil)
    local b=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_HOUSEKI)) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return a:GetCount()>0 and b:GetCount()>0 end
    local g=Duel.SelectCards(tp,a,1,1)
    g:Merge(Duel.SelectCards(tp,b:Filter(function(x) return not g:IsContains(x) end,nil),1,1))
    Duel.SendToTrash(g,REASON_COST+REASON_DISCARD)
  end)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,3)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e2:SetOperation(function(e,tp)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e2)
end
