-- WX04-088 幻獣　ビーグル
-- 【常】：このシグニが【ランサー】を持っているかぎり、このシグニの基本パワーは10000になる。
-- 【起】《緑》《緑》《緑》：ターン終了時まで、このシグニは【ランサー】を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,10000,function(e) return e:GetHandler():HasKeyword(EFFECT_LANCER) end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetRange(LOCATION_SZONE)
  e1:SetEnaCost("{G}{G}{G}")
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_LANCER) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
end
