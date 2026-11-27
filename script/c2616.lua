-- WX13-043 弩砲　トミガン
-- 【常】：このシグニはアタックできない。
-- 【自】：あなたのメインフェイズ開始時、あなたのセンタールリグが赤の場合、このシグニを場からトラッシュに置く。そうした場合、対戦相手のライフクロス１枚をクラッシュする。この効果でクラッシュされたカードのライフバーストは発動しない。（あなたのセンタールリグが赤の場合、この能力を発動しないことは選べない）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CANNOT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_PHASE_START+PHASE_MAIN)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp) local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return Duel.GetTurnPlayer()==tp and lc and lc:IsColor(COLOR_RED) end)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) and Duel.SendToTrash(h,REASON_EFFECT)>0 then Duel.Crush(1-tp,1,false,true) end
  end)
  c:RegisterEffect(e2)
end
