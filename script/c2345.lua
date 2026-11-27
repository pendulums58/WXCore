-- WX09-021 フィア＝ヴィックス
-- 【常】：対戦相手のシグニのパワーが対戦相手の効果によって＋（プラス）される場合、代わりに－（マイナス）される。
-- 【起】＜毒牙＞のシグニ１体を場からトラッシュに置く：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをこの方法でトラッシュに置いたシグニのレベル１につき－2000する。
-- ライフバースト：あなたのトラッシュから対象の＜毒牙＞のシグニ１枚を手札に加え、ターン終了時まで、対象の対戦相手のシグニ１体のパワーを－8000する。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_INVERT_PLUS)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(1,0)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  -- 자신이어도 된다(FAQ 5)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return g:GetCount()>0 end
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    e:SetLabel(x:GetLevel())
    Duel.SendToTrash(x,REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-2000*e:GetLabel()) end
  end)  -- [まで]
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    s.b=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
  end)
  e3:SetOperation(function(e,tp)
    if s.a and s.a:IsRelateToEffect(e) then Duel.SendToHand(s.a) end
    if s.b and s.b:IsRelateToEffect(e) then aux.AddPower(e,s.b,-8000) end
  end)
  c:RegisterEffect(e3)
end
