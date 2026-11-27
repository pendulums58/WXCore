-- WX14-002 コード・ピルルク　ＡＰＥＸ
-- 【自】《ターン１回》：あなたがスペルを使用したとき、対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》エクシード２：あなたのトラッシュから青か黒のスペル１枚を対象とし、それを手札にあるかのように使用する。それの使用コストは《青×1》《黒×1》減る。このターン、それがチェックゾーンから別の領域に移動される場合、代わりにゲームから除外される。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_USE_CARD)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp and eg:GetFirst():IsType(TYPE_SPELL) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetExceedCost(2)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) and (x:IsColor(COLOR_BLUE) or x:IsColor(COLOR_BLACK)) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local x=Duel.GetFirstTarget()
    if not (x and x:IsRelateToEffect(e)) then return end
    -- 《青×1》《黒×1》 줄여서 코스트를 내고 쓴다. 「代わりにゲームから除外」는 아직(트래시로 간다. 근사)
    for _,col in ipairs({"{U}","{B}"}) do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_REDUCE_COST)
      e1:SetProperty(EFFECT_FLAG_NEXT_USE)
      e1:SetTargetRange(1,0)
      e1:SetTarget(function(e,c) return c==x end)
      e1:SetEnaCost(col)
      e1:SetValue(1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
    Duel.UseFree(x,tp,true)
  end)
  c:RegisterEffect(e2)
end
