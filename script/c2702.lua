-- WX14-042 参ノ遊　フラフープ
-- 【常】：あなたの場にレゾナがあるかぎり、このシグニの基本パワーは12000になる。
-- 【自】：あなたのターン終了時、このシグニを場からトラッシュに置いてもよい。そうした場合、次の対戦相手のターン終了時まで、あなたのセンタールリグは「【起】《ターン１回》《アタックフェイズアイコン》《緑×0》：対戦相手のパワー12000以上のシグニ１体を対象とし、それをバニッシュする。」を得る。
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
    -- [まで] 「次の対戦相手のターン終了時まで」
    local g=Effect.CreateEffect(lc)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Stringid(id,0))
    g:SetRange(LOCATION_LRIG)
    g:SetCountLimit(1)
    g:SetTiming(TIMING_ATTACK)
    g:SetTarget(function(e2,tp2,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      Duel.SelectTarget(tp2,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp2,0,LOCATION_SZONE,1,1,nil)
    end)
    g:SetOperation(aux.BanishOp)
    g:SetReset(RESET_PHASE+PHASE_END,2)
    lc:GrantEffect(g)
  end)
  c:RegisterEffect(e1)
end
