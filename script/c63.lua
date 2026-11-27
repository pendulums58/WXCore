-- WX09-Re01 星占の巫女　リメンバ・デッドナイト
-- 【グロウ】あなたのセンタールリグがカード名に《リメンバ》を含む
-- 【常】：対戦相手の凍結状態のシグニは能力を失う。
-- 【起】エクシード１：対戦相手のシグニ１体を対象とし、それを凍結する。すでにそのシグニが凍結状態である場合、代わりにそれをバニッシュする。
-- 【起】《ターン１回》エクシード２：対戦相手の凍結状態のシグニ１体につきカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- 【グロウ】 센터 루리그 이름에 《リメンバ》(aux.NameHas)
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      return lc and aux.NameHas(lc,"リメンバ")
    end
  end)
  c:RegisterEffect(e0)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_LOSE_ABILITY)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(0,LOCATION_SZONE)
  e1:SetTarget(function(e,x) return x:IsFrozen() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_LRIG)
  e2:SetExceedCost(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if tc:IsFrozen() then Duel.Banish(tc) else Duel.Freeze(tc) end end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_LRIG)
  e3:SetExceedCost(2)
  e3:SetCountLimit(1)
  e3:SetOperation(function(e,tp)
    local n=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsFrozen() end,tp,0,LOCATION_SZONE,nil):GetCount()
    if n>0 then Duel.Draw(tp,n) end
  end)
  c:RegisterEffect(e3)
end
