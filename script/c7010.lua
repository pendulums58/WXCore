-- WXK10-036 コードＶＬ　アンジュ・カトリーナ
-- 【常】：あなたの＜電機＞のシグニのパワーを＋1000する。あなたの登録者数が５０万人を達成しているかぎり、代わりに＋2000する。
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、あなたの場に《コードＶＬ　リゼ・ヘルエスタ》がある場合、《無》を支払ってもよい。そうした場合、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) end)
  e1:SetValue(function(e) return Duel.GetSubscribers(e:GetHandlerPlayer())>=50 and 2000 or 1000 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and Duel.GetMatchingGroup(function(x) return x:IsCardName(7009) end,tp,LOCATION_SZONE,0,nil):GetCount()>0) then return end
    if not (Duel.CanPayEna(tp,"{C}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{C}"),REASON_COST)
    Duel.SendToHand(tc)
  end)
  c:RegisterEffect(e2)
end
