-- PR-319 幻蟲　オオムラサキ（ウィクロスマガジンvol.5 付録）
-- 【常】：あなたの場にレゾナがあるかぎり、このシグニの基本パワーは12000になる。
-- 【常】：あなたのターン終了時、このシグニを場からトラッシュに置いてもよい。そうした場合、次の対戦相手のターン終了時まで、あなたのセンタールリグは「【起】《ターン１回》《アタックフェイズアイコン》《黒×0》：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－7000する。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  aux.BasePower(c,12000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_RESONA) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 【常】로 적혀 있지만 「ターン終了時」에 하는 것이라 트리거로
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  -- 여러 장이면 능력도 여러 개(FAQ 1)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not Duel.SelectYesNo(tp) or Duel.SendToTrash(h,REASON_EFFECT)==0 then return end
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not lc then return end
    local g=Effect.CreateEffect(h)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Ability(id,1))
    g:SetRange(LOCATION_LRIG)
    g:SetTiming(TIMING_ATTACK)
    g:SetCountLimit(1)
    g:SetTarget(function(e2,tp2,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      Duel.SelectTarget(tp2,Card.IsSigni,tp2,0,LOCATION_SZONE,1,1,nil)
    end)
    g:SetOperation(function(e2,tp2)
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e2) then aux.AddPower(e2,tc,-7000) end
    end)
    g:SetReset(RESET_PHASE+PHASE_END,2)  -- [まで] 次の対戦相手のターン終了時まで
    lc:GrantEffect(g)
  end)
  c:RegisterEffect(e1)
end
