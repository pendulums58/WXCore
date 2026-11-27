-- WX10-088 幻蟲　ジガバチ
-- 【出】《黒×0》：対戦相手の場にある対象の【チャーム】１枚をトラッシュに置く。そうした場合、あなたのトラッシュから対象のレベル２以下の黒のシグニ１枚を手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.h=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetCharm()~=nil end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    s.t=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) and x:GetLevel()<=2 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
  end)
  e1:SetOperation(function(e,tp)
    -- 「対象の【チャーム】」: 그것이 붙은 시그니로 고른다
    local ch=s.h and s.h:IsRelateToEffect(e) and s.h:GetCharm()
    if not ch or Duel.SendToTrash(ch,REASON_EFFECT)==0 then return end
    if s.t and s.t:IsRelateToEffect(e) then Duel.SendToHand(s.t) end
  end)
  c:RegisterEffect(e1)
end
