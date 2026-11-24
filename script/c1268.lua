-- WD15-015 幻竜　アメリカワニ
-- 【自】：あなたの効果によって対戦相手のエナゾーンからカード１枚がトラッシュに置かれたとき、ターン終了時まで、このシグニは【ダブルクラッシュ】を得る。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(s.con)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not h:IsLocation(LOCATION_SZONE) then return end
    -- [まで] ターン終了時まで
    aux.GrantKeyword(e,h,EFFECT_DOUBLE_CRUSH)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
-- 「あなたの効果によって対戦相手のエナゾーンからカード１枚がトラッシュに置かれたとき」: 1장마다
function s.con(e,tp,eg,ep,ev,re,r,rp)
  local x=eg:GetFirst()
  return x:GetOwner()~=tp and x:IsPreviousLocation(LOCATION_ENA) and (r&REASON_EFFECT)~=0 and rp==tp
end
