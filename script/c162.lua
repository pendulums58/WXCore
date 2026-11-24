-- WD13-024 アーク・オーラ
-- ターン終了時まで、あなたのセンタールリグは「【自】：このルリグがアタックしたとき、あなたのシグニ１体を場からトラッシュに置いてもよい。そうした場合、このルリグをアップする。」を得る。
-- ライフバースト：対戦相手のセンタールリグとすべてのシグニをダウンする。
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
    e1:SetOperation(function(e,tp)
      local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
      local tc=Duel.SelectCards(tp,g,0,1):GetFirst()
      if tc and Duel.SendToTrash(tc)>0 then Duel.Up(e:GetHandler()) end
    end)
    lc:GrantEffect(e1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Down(Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG+LOCATION_SZONE,nil))
  end)
  c:RegisterEffect(e2)
end
