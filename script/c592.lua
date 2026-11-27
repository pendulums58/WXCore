-- WX14-003 紡ぐ者
-- 【常】：このルリグにグロウするためのルリグタイプは無視される。
-- 【常】：あなたはレベル５のシグニの限定条件を無視して場に出すことができる。
-- 【自】：対戦相手のシグニ１体がアタックしたとき、手札からそのシグニと共通する色を持つシグニを１枚捨ててもよい。そうした場合、そのアタックしているシグニはこのアタックであなたにダメージを与えない。
-- 【起】《無》：次のターンの間、対戦相手のルリグはあなたにダメージを与えない。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 「グロウするためのルリグタイプは無視」·「レベル５のシグニの限定条件を無視」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,2))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()~=tp and x:IsSigni() end)
  e1:SetOperation(function(e,tp,eg)
    local a=eg:GetFirst()
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetColor()&a:GetColor()~=0 end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    if Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD)==0 then return end
    -- 「このアタックであなたにダメージを与えない」: 다음 대미지 1번을 막는 것으로 근사
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_PREVENT_DAMAGE)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,3))
  e2:SetRange(LOCATION_LRIG)
  e2:SetEnaCost("{C}")
  e2:SetOperation(function(e,tp)
    -- [の間] 「次のターンの間」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_NO_LRIG_DAMAGE)
    e1:SetTargetRange(1,0)
    local now=Duel.GetTurnCount()
    e1:SetCondition(function() return Duel.GetTurnCount()==now+1 end)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e2)
end
