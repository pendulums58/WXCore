-- WXEX1-13 うるとらあーや！Ⅳ
-- 【自】：対戦相手のアタックフェイズ開始時、あなたの【トラップ】１つを対象とし、それを手札に戻してもよい。そうした場合、あなたのデッキの上からカードを２枚見る。その中からカード１枚を【トラップ】としてあなたのシグニゾーンに設置し、残りをデッキの一番下に置く。
-- 【起】《ターン１回》《アタックフェイズアイコン》《コインアイコン》：あなたのデッキの上からカードを５枚見る。その中から２枚までを【トラップ】としてあなたのシグニゾーンに設置する。残りをシャッフルしてデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_TRAP,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and Duel.SelectYesNo(tp)) then return end
    if Duel.SendToHand(tc)==0 then return end
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local pick=Duel.SelectCards(tp,g,1,1):GetFirst()
    if pick then Duel.SetTrap(pick,tp) end
    local rest=g:Filter(function(x) return x~=pick end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,false) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCountLimit(1)
  e2:SetCoinCost(1)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local pick=Duel.SelectCards(tp,g,0,2)
    for x in pick:Iter() do Duel.SetTrap(x,tp) end
    local rest=g:Filter(function(x) return not pick:IsContains(x) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e2)
end
