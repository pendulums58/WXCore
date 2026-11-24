-- WD14-023 エニグマ・オーラ
-- ターン終了時まで、あなたのセンタールリグは「【自】：このルリグがアタックしたとき、あなたのシグニを好きな数対象とし、それらを場からトラッシュに置く。その後、この方法でトラッシュに置いたシグニ１体につきデッキの上からカードを１枚ライフクロスに加える。」を得る。
-- ライフバースト：あなたのトラッシュから黒のシグニ１枚を対象とし、それを場に出す。それの【出】能力は発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not lc then return end
    -- [まで] ターン終了時まで
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetDescription(aux.Ability(id,0))
    e1:SetCode(EVENT_ATTACK)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,0,99,nil)
    end)
    e1:SetOperation(function(e,tp)
      local n=Duel.SendToTrash(Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil),REASON_EFFECT)
      for _=1,n do Duel.SendToLife(Duel.GetDecktopGroup(tp,1)) end
    end)
    lc:GrantEffect(e1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp,true) end
  end)
  c:RegisterEffect(e2)
end
