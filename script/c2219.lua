-- WX07-050 羅星　アルヘナ
-- 【出】手札から＜宇宙＞のシグニを１枚捨てる：あなたのルリグデッキからレベル３以下の白のレゾナ１枚をその出現条件を無視して場に出す。ターン終了時、そのレゾナを場からルリグデッキに戻す。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_UCHU)) end))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_RESONA) and x:IsColor(COLOR_WHITE) and x:GetLevel()<=3 end,tp,LOCATION_LDECK,0,nil)
    local x=Duel.SelectCards(tp,g,0,1):GetFirst()
    if not (x and Duel.PutOnField(x,tp)) then return end
    -- 「ターン終了時」 장에 있을 때만 루리그 덱으로(FAQ 1)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_TURN_END)
    e1:SetCountLimit(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetOperation(function() if x:IsLocation(LOCATION_SZONE) then Duel.SendToLrigDeck(x) end end)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
