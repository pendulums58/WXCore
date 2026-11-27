-- WX15-034 戦意の箱舟
-- あなたの場にパワー15000以上のシグニがある場合、このスペルの使用コストは《赤×2》減る。
-- 以下の２つから２つまでを選ぶ。
-- ①あなたのデッキから＜武勇＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ②対戦相手のシグニ１体を対象とし、あなたの場に《ライズアイコン》を持つシグニがある場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) if Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetPower()>=15000 end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then return Duel.ReduceCost(base,"{R}",2) end return base end)
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.t=e:GetLabel()&2~=0 and Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BUYU)) end,1) end
    if m&2~=0 and s.t and s.t:IsRelateToEffect(e) and Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.Banish(s.t) end
  end)
  c:RegisterEffect(e1)
end
