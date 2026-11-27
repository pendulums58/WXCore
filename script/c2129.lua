-- WX05-076 魅惑の魔道　ロキ
-- 【常】：あなたの他の＜悪魔＞のシグニのパワーを＋2000する。
-- ライフバースト：あなたのデッキから＜悪魔＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x~=e:GetHandler() and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end)(x) end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end,1)
  end)
  c:RegisterEffect(e2)
end
