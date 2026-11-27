-- WX22-034 月光の狩猟　アルテミス
-- 【出】《無》：あなたのトラッシュから＜天使＞のシグニ１枚を対象とし、それをこのシグニの下に置く。
-- 【常】：このシグニがバニッシュされる場合、代わりにこのシグニの下からカード１枚をトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{C}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then local h=e:GetHandler() if h:IsLocation(LOCATION_SZONE) then Duel.PutUnder(h,Group.CreateGroup(tc)) end end
  end)
  c:RegisterEffect(e1)
  -- 【常】 「代わりに下からカード１枚をトラッシュ」 대체는 아직(근사 없음)
end
