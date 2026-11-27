-- WX16-039 鎌振の十勇　ユリカマ
-- 【自】：このシグニがライズされたとき、ターン終了時まで、そのシグニは【ダブルクラッシュ】を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_RISEN)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetRiser()
    if tc and tc:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,tc,EFFECT_DOUBLE_CRUSH) end
  end)
  c:RegisterEffect(e1)
end
