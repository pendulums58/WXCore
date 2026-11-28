-- WXK09-TK-01A 改造素材
-- このターン、あなたは《改造素材》を使用できない。以下の３つから１つを選ぶ。
-- ①あなたの＜電機＞のシグニ１体を対象とし、ターン終了時まで、それのパワーを＋4000する。
-- ②あなたの＜電機＞のシグニ１体を対象とし、《緑》を支払ってもよい。そうした場合、ターン終了時まで、それは「【起】《ダウン》：このシグニよりパワーの低い対戦相手のシグニ１体を対象とし、それをバニッシュする。」を得る。
-- ③あなたの＜電機＞のシグニ１体を対象とし、《緑》《緑》を支払ってもよい。そうした場合、ターン終了時まで、それは「【自】《ターン１回》：このシグニがアタックしたとき、このシグニをアップする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) return not Duel.IsPlayerAffected(tp,6974001) end)
  e1:SetOperation(function(e,tp,eg)
    -- [まで] このターン
    local e0=Effect.CreateEffect(e:GetHandler())
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(6974001)
    e0:SetTargetRange(1,0)
    e0:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e0,tp)
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if not tc then return end
    if m==0 then aux.AddPower(e,tc,4000)
    elseif m==1 then
      if not (Duel.CanPayEna(tp,"{G}") and Duel.SelectYesNo(tp)) then return end
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_IGNITION)
      g:SetDescription(aux.Stringid(id,3))
      g:SetRange(LOCATION_SZONE)
      g:SetCost(aux.SelfDownCost)
      g:SetOperation(function(e,tp)
        local h=e:GetHandler()
        local x=Duel.SelectTarget(tp,function(y) return y:IsSigni() and y:GetPower()<h:GetPower() end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if x then Duel.Banish(x) end
      end)
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_GRANT)
      e1:SetLabelObject(g)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
    else
      if not (Duel.CanPayEna(tp,"{G}{G}") and Duel.SelectYesNo(tp)) then return end
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}{G}"),REASON_COST)
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
      g:SetDescription(aux.Stringid(id,4))
      g:SetCode(EVENT_ATTACK)
      g:SetCountLimit(1)
      g:SetOperation(function(e) local h=e:GetHandler() if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end end)
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_GRANT)
      e1:SetLabelObject(g)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
    end
    Duel.RaiseEvent(EVENT_CUSTOM+6974,tc,tp)
  end)
  c:RegisterEffect(e1)
end
