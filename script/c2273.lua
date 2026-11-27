-- WX08-027 コードアート　Ｈ・Ｉ
-- 《クロスアイコン》《コードアート　Ｄ・Ｙ》の右
-- 【クロス常】：このシグニの基本パワーは15000になる。
-- 【起】手札から＜電機＞のシグニを１枚捨てる：対戦相手のシグニ１体を対象とし、それを凍結する。
-- 【クロス自】：このシグニが《ヘブン》したとき、対戦相手の凍結状態のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：対戦相手のすべてのシグニをダウンする。その後、対戦相手のシグニ１体を対象とし、それを凍結する。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2286,CROSS_RIGHT)
  -- [の間] 【クロス常】
  aux.BasePower(c,15000,function(e) return e:GetHandler():IsCross() end)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI)) end))
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
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_HEAVEN)
  e3:SetRange(LOCATION_SZONE)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsFrozen() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    Duel.Down(Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil))
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Freeze(tc) end
  end)
  c:RegisterEffect(e4)
end
