-- WX22-042 葡萄の松笠　＃デュオニソ＃
-- 【起】《ターン１回》《緑×0》：色１つを宣言する。ターン終了時まで、このシグニは色を失い、宣言した色を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetOperation(function(e,tp)
    local cols={COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_GREEN,COLOR_BLACK}
    local c=cols[Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4))+1]
    local h=e:GetHandler()
    if not h:IsLocation(LOCATION_SZONE) then return end
    local e1=Effect.CreateEffect(h)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_COLOR)
    e1:SetValue(c)
    e1:SetReset(RESET_PHASE+PHASE_END)
    h:RegisterEffect(e1)
  end)
  c:RegisterEffect(e1)
end
