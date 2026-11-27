-- WX08-060 相愛の調律
-- 対象の対戦相手のパワー5000以下のシグニ１体をバニッシュする。あなたの場にクロス状態のシグニがある場合、ターン終了時まで、対象のあなたのシグニ１体は【ダブルクラッシュ】を得る。
-- ライフバースト：あなたのデッキから《クロスアイコン》を持つシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=5000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    s.b=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsCross() end,tp,LOCATION_SZONE,0,nil):GetCount()>0 and Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    if s.a and s.a:IsRelateToEffect(e) then Duel.Banish(s.a) end
    if s.b and s.b:IsRelateToEffect(e) then aux.GrantKeyword(e,s.b,EFFECT_DOUBLE_CRUSH) end  -- [まで]
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:HasCrossIcon() end,1)
  end)
  c:RegisterEffect(e2)
end
