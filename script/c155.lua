-- WX21-Re19 羅星　アルデバラン
-- 【常】：あなたの場にレゾナがあるかぎり、このシグニの基本パワーは12000になる。
-- 【自】：あなたのターン終了時、このシグニを場からトラッシュに置いてもよい。そうした場合、次のあなたのターンまで、あなたのセンタールリグは「【起】《ターン１回》《アタックフェイズアイコン》《白×0》：対戦相手のレベル３以下のシグニ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,12000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_RESONA) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) or Duel.SendToTrash(h,REASON_EFFECT)==0 then return end
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not lc then return end
    -- [まで] 「次のあなたのターンまで」
    local g=Effect.CreateEffect(lc)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Stringid(id,0))
    g:SetRange(LOCATION_LRIG)
    g:SetCountLimit(1)
    g:SetTiming(TIMING_ATTACK)
    g:SetTarget(function(e2,tp2,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      Duel.SelectTarget(tp2,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp2,0,LOCATION_SZONE,1,1,nil)
    end)
    g:SetOperation(function(e2)
      local tc=Duel.GetFirstTarget()
      if not (tc and tc:IsRelateToEffect(e2)) then return end
      local e1=Effect.CreateEffect(e2:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_CANNOT_ATTACK)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e1)
    end)
    g:SetReset(RESET_PHASE+PHASE_END,2)
    lc:GrantEffect(g)
  end)
  c:RegisterEffect(e1)
end
