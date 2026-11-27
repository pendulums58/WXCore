-- WX12-001 永らえし者　タウィル＝フェム
-- 【常】：このルリグはこのカードの下にあるルリグの【起】能力を持つ。
-- 【自】：対戦相手のシグニ１体がアタックしたとき、手札から＜天使＞のシグニを２枚捨ててもよい。そうした場合、そのアタックしているシグニはこのアタックであなたにダメージを与えない。
-- 【自】：あなたのターン終了時、トラッシュから＜天使＞のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 아래 루리그의 【起】(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UNDER_IGNITION)
  e1:SetRange(LOCATION_LRIG)
  c:RegisterEffect(e1)
  -- 「このアタックで…ダメージを与えない」: 다음 대미지 하나를 막는 것으로 근사
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetRange(LOCATION_LRIG)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()~=tp and x:IsSigni() end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()<2 or not Duel.SelectYesNo(tp) then return end
    if Duel.SendToTrash(Duel.SelectCards(tp,g,2,2),REASON_EFFECT+REASON_DISCARD)<2 then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_PREVENT_DAMAGE)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_TURN_END)
  e3:SetRange(LOCATION_LRIG)
  e3:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
end
