-- WXK04-090 幻水　コケケロ
-- 【出】：あなたの手札から＜水獣＞のシグニを１枚公開しないかぎり、このシグニを場からトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    if aux.RevealFromHand(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end,1):GetCount()>0 then return end
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.SendToTrash(h,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
