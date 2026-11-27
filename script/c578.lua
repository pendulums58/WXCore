-- WX05-022 コードラブハート　Ｃ・Ｍ・Ｒ
-- 【常】：対戦相手は自分のターンの間、グロウフェイズとドローフェイズ以外でカードを引いたりカードを手札に加えることができない。
-- 【起】《ターン１回》手札をすべて捨てる：対戦相手のシグニ１体を対象とし、この方法で手札を２枚以上捨てた場合、それをバニッシュする。
-- ライフバースト：対戦相手のセンタールリグ１体を対象とし、それをダウンし凍結する。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 상대는 자기 턴에 그로우·드로 페이즈 밖에서 뽑거나 패에 넣을 수 없다(FAQ 1·2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_NO_HAND_ADD)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,1)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    e:SetLabel(g:GetCount()>0 and Duel.SendToTrash(g,REASON_COST+REASON_DISCARD) or 0)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if e:GetLabel()>=2 and tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc)
        Duel.Freeze(tc) end
  end)
  c:RegisterEffect(e3)
end
