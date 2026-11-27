-- WX22-018 幻怪姫　ネコマター
-- 【常】：すべてのプレイヤーはコストの合計が０のスペルを使用できない。
-- 【自】：このシグニがアタックしたとき、あなたはいずれかのトラッシュから対象のコストの合計が０のスペル１枚をゲームから除外し《無》を支払ってもよい。そうした場合、対象の対戦相手のシグニ１体を手札に戻す。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CANNOT_USE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(1,1)
  e1:SetTarget(function(e,x) return x:IsType(TYPE_SPELL) and x:GetCostTotal()==0 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) and x:GetCostTotal()==0 end,tp,LOCATION_TRASH,LOCATION_TRASH,0,1,nil)
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local all=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    local sp=all:Filter(function(x) return x:IsLocation(LOCATION_TRASH) end,nil):GetFirst()
    local tc=all:Filter(function(x) return x:IsLocation(LOCATION_SZONE) end,nil):GetFirst()
    if not sp or not Duel.CanPayEna(tp,"{C}") or not Duel.SelectYesNo(tp) then return end
    Duel.Exclude(sp)
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{C}"),REASON_COST)
    if tc then Duel.SendToHand(tc) end
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
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
end
