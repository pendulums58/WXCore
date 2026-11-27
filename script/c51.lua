-- WX09-Re11 羅石　アンモライト
-- 【自】：あなたが赤のスペルを使用したとき、ターン終了時まで、このシグニは【ダブルクラッシュ】を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_USE_CARD)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) local x=eg:GetFirst() return ep==tp and x:IsType(TYPE_SPELL) and x:IsColor(COLOR_RED) end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_DOUBLE_CRUSH) end  -- [まで]
  end)
  c:RegisterEffect(e1)
end
