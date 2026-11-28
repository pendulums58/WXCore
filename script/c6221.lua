-- WXK01-038 強奪の箱舟
-- ターン終了時まで、あなたのセンタールリグはあなたのすべての＜乗機＞のシグニに乗る。
-- ターン終了時まで、あなたのセンタールリグは「【自】：あなたのルリグアタックステップ開始時、あなたのシグニを好きな数対象とし、それらを場からトラッシュに置く。その後、この方法でトラッシュに置いたシグニ１体につき対戦相手の手札を１枚見ないで選び、捨てさせる。」を得る。
-- ライフバースト：対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    -- 쓴 때 장에 있는 것만(FAQ 1)
    for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_JOUKI) end,tp,LOCATION_SZONE,0,nil):Iter() do Duel.Ride(x,true) end  -- [まで] ターン終了時まで
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not lc then return end
    local g=Effect.CreateEffect(e:GetHandler())
    g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    g:SetDescription(aux.Stringid(id,0))
    g:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
    g:SetRange(LOCATION_LRIG)
    g:SetCondition(function(e2,tp2) return Duel.GetTurnPlayer()==tp2 end)
    -- 루리그 어택 스텝 개시 시(근사: 어택 페이즈 개시 시)
    g:SetOperation(function(e2,tp2)
      local t=Duel.SelectTarget(tp2,Card.IsSigni,tp2,LOCATION_SZONE,0,0,3,nil)
      local n=t:GetCount()>0 and Duel.SendToTrash(t,REASON_EFFECT) or 0
      local h=Duel.GetMatchingGroup(nil,tp2,0,LOCATION_HAND,nil)
      local k=math.min(n,h:GetCount())
      if k>0 then Duel.SendToTrash(Duel.SelectCards(tp2,h,k,k),REASON_EFFECT+REASON_DISCARD) end
    end)
    g:SetReset(RESET_PHASE+PHASE_END)
    lc:GrantEffect(g)
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(aux.BanishPowerTarget(12000))
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if tc:GetPower()<=12000 then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e9)
end
