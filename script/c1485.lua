-- WX22-001 悲願の駄姫　グズ子
-- 【出】：あなたのトラッシュから＜遊具＞のシグニを２枚まで対象とし、それらを場に出す。
-- 【起】《ターン１回》《メインフェイズアイコン》《アタックフェイズアイコン》《黒×0》：対戦相手のシグニ１体を対象とし、あなたの＜遊具＞のシグニ１体を場からトラッシュに置く。そうした場合、ターン終了時まで、それのパワーを－12000する。
-- 【起】《アタックフェイズアイコン》《コインアイコン》《コインアイコン》：このアタックフェイズの間、あなたの＜遊具＞のシグニ１体が場を離れたとき、あなたの手札からそのシグニより低いレベルを持つ＜遊具＞のシグニ１枚を場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    for x in Duel.GetTargets():Iter() do if x:IsRelateToEffect(e) then Duel.PutOnField(x,tp) end end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()==0 or Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT)==0 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-12000) end  -- [まで]
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCoinCost(2)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetOperation(function(e,tp)
    -- [の間] 「このアタックフェイズの間」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_LEAVE_FIELD)
    e1:SetCondition(function(e2,tp2,eg) local x=eg:GetFirst() return Duel.GetPhase()==PHASE_ATTACK and x:GetOwner()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end)(x) end)
    e1:SetOperation(function(e2,tp2,eg)
      local lv=eg:GetFirst():GetLevel()
      local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end)(c) and c:GetLevel()<lv end,tp,LOCATION_HAND,0,nil),1,1):GetFirst()
      if x then Duel.PutOnField(x,tp) end
    end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e3)
end
