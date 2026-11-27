-- WX04-046 コードアート　Ａ・Ｃ・Ｇ
-- 【常】：対戦相手は、カードの効果を除き、自分で自分のシグニを場からトラッシュに置くことができない。
-- 【起】《ダウン》：対戦相手のシグニ１体を対象とし、それを凍結する。
-- （凍結されたシグニは次のアップフェイズにアップしない）
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをダウンし凍結する。カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 카드의 효과·코스트는 된다(FAQ 3·4)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_NO_REMOVE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,1)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(aux.SelfDownCost)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Freeze(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.Down(tc)
      Duel.Freeze(tc)
    end
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
end
