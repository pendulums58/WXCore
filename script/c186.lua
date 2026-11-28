-- PR-305 エンジェルキラー　†上柚木綾瀬†（Z/Xコラボイベント 景品）
-- 【自】：あなたのターンの間、このシグニがバトルしたとき、手札を１枚捨ててもよい。そうした場合、そのバトル終了時にこのシグニがバトルしたそのシグニを場からデッキの一番下に置く。
-- 【出】：対戦相手の＜天使＞のシグニ１体を対象とし、あなたのセンタールリグが黒の場合、それをバニッシュする。
-- 【出】《黒》：対戦相手のレベル３のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BATTLE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  -- 「バトル終了時」에 덱 맨 아래로: 배틀하고 남았을 때로 근사(이미 바니시됐으면 아무 일도 없다. FAQ 1)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetBattleOpponent()
    if not x or Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    if aux.Discard(tp,1)==0 then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_PHASE_START+PHASE_END)
    e1:SetCountLimit(1)
    e1:SetOperation(function() if x:IsLocation(LOCATION_SZONE) then Duel.SendToDeckBottom(x,false) end end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() if lc and lc:IsColor(COLOR_BLACK) then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{B}")
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==3 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
end
