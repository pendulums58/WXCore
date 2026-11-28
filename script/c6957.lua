-- WXK09-084 コードアート　Ｃ・Ｒ・Ｃ
-- 【自】：あなたの他のシグニ１体に《改造素材》が使用されたとき、ターン終了時まで、そのシグニは【ランサー】を得る。
-- （【ランサー】を持つシグニがバトルでシグニをバニッシュしたとき、対戦相手のライフクロスを１枚クラッシュする）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CUSTOM+6974)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x and x~=e:GetHandler() and x:GetControler()==tp end)
  e1:SetOperation(function(e,tp,eg)
    local x=eg:GetFirst()
    if x:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,x,EFFECT_LANCER) end
  end)
  c:RegisterEffect(e1)
end
