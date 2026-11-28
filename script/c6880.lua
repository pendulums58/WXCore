-- WXK09-006 天色の巫女　タマヨリヒメ
-- 【自】：あなたのアタックフェイズ開始時、以下の３つから１つを選ぶ。
-- ①あなたのトラッシュから＜天使＞のシグニ１枚を対象とし、それを手札に加える。
-- ②次の対戦相手のターンの間、対戦相手のアーツとスペルの使用コストは《無×2》増える。
-- ③対戦相手のシグニ１体を対象とし、対戦相手の手札が０枚の場合、それをバニッシュする。
-- 【起】《ゲーム１回》《アタックフェイズアイコン》イノセンス《コインアイコン》：あなたのトラッシュから能力を持たないシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp,eg)
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
    if m==0 then
      local x=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if x then Duel.SendToHand(x) end
    elseif m==1 then
      -- 「次の対戦相手のターンの間、対戦相手のアーツとスペルの使用コストは《無×2》増える」는 아직
    else
      local x=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if x and Duel.GetMatchingGroup(nil,1-tp,LOCATION_HAND,0,nil):GetCount()==0 then Duel.Banish(x) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCountLimit(1,true)
  e2:SetCoinCost(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:HasAbility() end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.PutOnField(tc,tp)
    end
  end)
  c:RegisterEffect(e2)
end
