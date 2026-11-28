-- WXEX1-28 黒幻蟲　アンブリ・パイギ
-- 【出現条件】《メインフェイズアイコン》《アタックフェイズアイコン》合計５枚のレゾナではない＜凶蟲＞のシグニをあなたのエナゾーンと場からトラッシュに置く
-- 【起】《ターン１回》《メインフェイズアイコン》《アタックフェイズアイコン》《黒×0》：対象の対戦相手のシグニ１体を対象の対戦相手の他のシグニ１体の【チャーム】にする。
-- 【起】《ターン１回》《メインフェイズアイコン》《アタックフェイズアイコン》《黒×0》：対戦相手の場にある対象の【チャーム】１枚をトラッシュに置く。そうした場合、あなたのトラッシュから対象の＜凶蟲＞のシグニ１枚を手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,5,aux.NonResonaClass(RACE_KYOUCHU),LOCATION_ENA+LOCATION_SZONE,TIMING_MAIN+TIMING_ATTACK)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetRange(LOCATION_SZONE)
  e1:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e1:SetCountLimit(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local t1=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if t1 then
      Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:GetCharm() end,tp,0,LOCATION_SZONE,1,1,t1)
    end
  end)
  e1:SetOperation(function(e,tp)
    local tg=Duel.GetTargets()
    local arr={}
    for x in tg:Iter() do arr[#arr+1]=x end
    if arr[1] and arr[2] and arr[1]:IsRelateToEffect(e) and arr[2]:IsRelateToEffect(e) then
      Duel.Charm(arr[1],arr[2])
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetCountLimit(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetCharm()~=nil end,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_KYOUCHU),tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tg=Duel.GetTargets():Filter(Card.IsRelateToEffect,nil,e)
    local host,rec
    for x in tg:Iter() do
      if x:IsLocation(LOCATION_SZONE) then host=x
      elseif x:IsLocation(LOCATION_TRASH) then rec=x end
    end
    local ch=host and host:GetCharm()
    if ch and Duel.SendToTrash(ch,REASON_EFFECT)>0 and rec then Duel.SendToHand(rec) end
  end)
  c:RegisterEffect(e2)
end
