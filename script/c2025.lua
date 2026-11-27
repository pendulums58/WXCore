-- WX04-047 羅原　Ｈｅ
-- 【起】《ダウン》：カードを２枚引く。あなたは手札から＜原子＞のシグニを１枚捨てないかぎり手札を２枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  -- ＜原子＞를 버리지 않으면 2장(FAQ 1)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
    local a=Duel.SelectDiscard(tp,0,1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end)
    if a:GetCount()>0 and Duel.SendToTrash(a,REASON_EFFECT+REASON_DISCARD)>0 then return end
    aux.Discard(tp,2)
  end)
  c:RegisterEffect(e1)
end
