-- WX04-054 サーバント　Ｘ
-- 【常】：カード名に《サーバント》を含むあなたの他のシグニのパワーを＋3000する。
-- 【常】：【マルチエナ】
-- 【起】《無》《無》《無》：あなたのデッキからカード名に《サーバント》を含むシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x~=e:GetHandler() and (function(x) return x:IsSigni() and x:IsClass(SYS_SEIGEN,0) end)(x) end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  -- [の間] 【常】 에나 존에서만
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_MULTI_ENA)
  e2:SetRange(LOCATION_ENA)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetEnaCost("{C}{C}{C}")
  -- 「サーバント」는 ＜精元＞로 본다. 자신도 찾을 수 있다(FAQ 2)
  e3:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsClass(SYS_SEIGEN,0) end,1)
  end)
  c:RegisterEffect(e3)
end
