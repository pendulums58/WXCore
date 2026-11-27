-- WX14-075 探究の死相　†ハニエル†
-- 【出】：あなたの手札から＜天使＞のシグニ１枚を公開するか、このシグニを場からトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_HAND,0,nil)
    local h=e:GetHandler()
    -- 예 = 패의 ＜天使＞를 공개, 아니오 = 이 시그니를 트래시에
    if g:GetCount()>0 and Duel.SelectYesNo(tp) then
      Duel.RevealCards(Duel.SelectCards(tp,g,1,1))
      
    elseif h:IsLocation(LOCATION_SZONE) then
      Duel.SendToTrash(h,REASON_EFFECT)
    end
  end)
  c:RegisterEffect(e1)
end
