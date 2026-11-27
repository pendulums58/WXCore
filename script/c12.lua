-- WX09-Re18 増援
-- 以下の２つから１つを選ぶ。
-- ①あなたのデッキからパワー10000以上のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ②あなたのデッキの上からカードを２枚エナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then aux.SearchToHand(tp,function(x) return x:IsSigni() and x:GetPower()>=10000 end,1) else Duel.EnaCharge(tp,2) end
  end)
  c:RegisterEffect(e1)
end
