-- WX05-045 ファイナル・ディストラクション
-- ターン終了時まで、あなたのセンタールリグは「【起】《ダウン》：対戦相手のすべてのシグニをバニッシュする。」を得る。
-- このターン終了時、あなたは手札をすべて捨てる。
-- ライフバースト：手札をすべて捨てる。そうした場合、すべてのシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [まで] 센터 루리그가 얻는다
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if lc then
      local g=Effect.CreateEffect(lc)
      g:SetType(EFFECT_TYPE_IGNITION)
      g:SetDescription(aux.Stringid(id,0))
      g:SetRange(LOCATION_LRIG)
      g:SetCost(aux.SelfDownCost)
      g:SetOperation(function(e,tp)
        local og=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
        if og:GetCount()>0 then Duel.Banish(og) end
      end)
      g:SetReset(RESET_PHASE+PHASE_END)
      lc:GrantEffect(g)
    end
    -- 「このターン終了時」
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCode(EVENT_TURN_END)
    e2:SetReset(RESET_PHASE+PHASE_END)
    e2:SetOperation(function(e2,tp2)
      local h=Duel.GetMatchingGroup(nil,tp2,LOCATION_HAND,0,nil)
      if h:GetCount()>0 then Duel.SendToTrash(h,REASON_EFFECT+REASON_DISCARD) end
    end)
    Duel.RegisterEffect(e2,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  -- 패가 0장이어도 바니시한다(FAQ 2)
  e2:SetOperation(function(e,tp)
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if h:GetCount()>0 then Duel.SendToTrash(h,REASON_EFFECT+REASON_DISCARD) end
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e2)
end
