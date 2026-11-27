-- WX09-018 コードハート　Ａ・Ｍ・Ｓ
-- 【常】：あなたのトラッシュにスペルが５枚以上あるかぎり、このシグニの基本パワーは15000になり、このシグニは対戦相手のシグニの効果を受けない。
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、このターンにあなたがスペルを３回以上使用していた場合、それをバニッシュする。
-- 【起】《ダウン》：このターン、あなたが次にスペルを使用する場合、それの使用コストは《無×2》減る。
-- ライフバースト：あなたのトラッシュからスペルを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,15000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=5 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=5 end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsSigni() end)
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
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetSpellsUsedCount(tp)>=3 then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetCost(aux.SelfDownCost)
  e3:SetOperation(function(e,tp)
    -- [の間] 「このターン、次に」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_REDUCE_COST)
    e1:SetProperty(EFFECT_FLAG_NEXT_USE)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,x) return x:IsType(TYPE_SPELL) end)
    e1:SetEnaCost("{C}")
    e1:SetValue(2)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e4:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e4)
end
