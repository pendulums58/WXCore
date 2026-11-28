-- WXEX1-48 コードアンチ　マカナ
-- 【自】：このカードがデッキからトラッシュに置かれたとき、このカードをトラッシュから場に出してもよい。
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、あなたの場にあるダウン状態のシグニが１体の場合、それをバニッシュする。
-- 【起】《アタックフェイズアイコン》このシグニを場からトラッシュに置く：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－12000する。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－12000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e,tp) return e:GetHandler():IsPreviousLocation(LOCATION_MDECK) end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) then Duel.PutOnField(h,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsDown() end,tp,LOCATION_SZONE,0,nil):GetCount()~=1 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SendToTrash(e:GetHandler(),REASON_COST)
  end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-12000) end
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-12000) end
  end)
  c:RegisterEffect(e9)
end
