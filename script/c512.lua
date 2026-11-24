-- WD17-008 瞬息爆変
-- あなたのデッキから赤のシグニ１枚を探してダウン状態で場に出し、デッキをシャッフルする。ターン終了時、そのシグニを場からトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    Duel.ConfirmCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil))
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_RED) end,tp,LOCATION_MDECK,0,nil)
    local tc=Duel.SelectCards(tp,g,0,1):GetFirst()
    local ok=tc and Duel.PutOnField(tc,tp)
    if ok then Duel.Down(tc) end
    Duel.SendToDeckShuffle(Group.CreateGroup(),tp)
    if not ok then return end
    -- 그 객체에 건다. 라이즈되거나 장을 떠나면 끊긴다(FAQ 1·2)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetDescription(aux.Ability(id,0))
    e1:SetCode(EVENT_TURN_END)
    e1:SetRange(LOCATION_SZONE)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetOperation(function(e1)
      local h=e1:GetHandler()
      if h:IsLocation(LOCATION_SZONE) then Duel.SendToTrash(h,REASON_EFFECT) end
    end)
    tc:RegisterEffect(e1)
  end)
  c:RegisterEffect(e1)
end
