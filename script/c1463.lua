-- WX21-001 ドーナ　ＦＩＦＴＨ
-- 【自】：各アタックフェイズ開始時、以下の３つから１つを選ぶ。
-- ①あなたの＜怪異＞のシグニ１体を対象とし、ターン終了時まで、それは【アサシン】を得る。
-- ②あなたの＜怪異＞のシグニ１体を対象とし、ターン終了時まで、それのパワーを＋10000する。
-- ③あなたのトラッシュから＜怪異＞のシグニ１枚を対象とし、それを手札に加える。
-- 【起】《アタックフェイズアイコン》《コインアイコン》《コインアイコン》：あなたの＜怪異＞のシグニを３体まで対象とし、それらを手札に戻す。その後、手札から＜怪異＞のシグニを３枚まで場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_LRIG)
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetCondition(function(e,tp) return true end)
  e1:SetOperation(function(e,tp)
    local m=Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))[1]
    if m==2 then
      local x=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if x then Duel.SendToHand(x) end
      return
    end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if not tc then return end
    if m==0 then aux.GrantKeyword(e,tc,EFFECT_ASSASSIN) else aux.AddPower(e,tc,10000) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCoinCost(2)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end,tp,LOCATION_SZONE,0,0,3,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
    for x in Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end,tp,LOCATION_HAND,0,nil),0,3):Iter() do Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e2)
end
