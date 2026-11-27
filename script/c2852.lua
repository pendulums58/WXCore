-- WX16-029 大罠　ルパンヌ
-- 【自】：対戦相手のターンの間、このシグニがバニッシュされたとき、このシグニをエナゾーンから【トラップ】としてあなたのシグニゾーンに設置してもよい。
-- 《トラップアイコン》：アタックしているシグニ１体を対象とし、手札から＜トリック＞のシグニを１枚捨ててもよい。そうした場合、それはこのアタックであなたにダメージを与えない。
-- ライフバースト：あなたのデッキから＜トリック＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_ENA) and Duel.SelectYesNo(tp) then Duel.SetTrap(h,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_TRAP)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TRICK)) end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD)
    -- 「このアタックであなたにダメージを与えない」: 다음 대미지 1번을 막는 것으로 근사
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_PREVENT_DAMAGE)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_TRICK)) end,1)
  end)
  c:RegisterEffect(e3)
end
