-- WX04-094 怒号
-- あなたの＜空獣＞か＜地獣＞のシグニ１体を対象とし、ターン終了時まで、それのパワーを＋2000する。あなたの場に＜空獣＞と＜地獣＞のシグニが合計３体ある場合、ターン終了時まで、それは【ランサー】と「【自】：このシグニが対戦相手のライフクロスをクラッシュしたとき、あなたのデッキの一番上のカードをエナゾーンに置く。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU)) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  -- 조건은 처리할 때 본다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    aux.AddPower(e,tc,2000)  -- [まで] ターン終了時まで
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU)) end,tp,LOCATION_SZONE,0,nil):GetCount()<3 then return end
    aux.GrantKeyword(e,tc,EFFECT_LANCER)
    local g=Effect.CreateEffect(tc)
    g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    g:SetDescription(aux.Stringid(id,0))
    g:SetCode(EVENT_CRUSHED)
    g:SetRange(LOCATION_SZONE)
    g:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetCrusher()==e:GetHandler() end)
    g:SetOperation(aux.EnaChargeOp(1))
    g:SetReset(RESET_PHASE+PHASE_END)
    tc:GrantEffect(g)
  end)
  c:RegisterEffect(e1)
end
