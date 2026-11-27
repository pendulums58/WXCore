-- WX11-031 幻獣神　ウルティム
-- 【自】：このシグニが対戦相手のシグニ１体をバニッシュしたとき、このターンにあなたの＜空獣＞か＜地獣＞のシグニが対戦相手のシグニを合計３体バニッシュしていた場合、このシグニをアップする。
-- ライフバースト：次のターンの間、あなたの中央のシグニゾーンにあるシグニのパワーは＋5000され、それは【ランサー】を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- 이 턴 ＜空獣＞·＜地獣＞가 바니시한 상대 시그니 수를 센다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() local b=Duel.GetBanisher() if not (b and x:GetOwner()~=tp and b:GetControler()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU)) end)(b)) then return false end local t=Duel.GetTurnCount() if s.turn~=t then s.turn,s.n=t,0 end s.n=s.n+1 return b==e:GetHandler() and s.n>=3 end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    -- [の間] 「次のターンの間」
    local now=Duel.GetTurnCount()
    for _,code in ipairs({EFFECT_UPDATE_POWER,EFFECT_LANCER}) do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(code)
      e1:SetTargetRange(LOCATION_SIGNI,0)
      e1:SetTarget(function(e,x) return x:IsInZone("signi_center") end)
      e1:SetCondition(function() return Duel.GetTurnCount()==now+1 end)
      if code==EFFECT_UPDATE_POWER then e1:SetValue(5000) end
      e1:SetReset(RESET_PHASE+PHASE_END,2)
      Duel.RegisterEffect(e1,tp)
    end
  end)
  c:RegisterEffect(e2)
end
