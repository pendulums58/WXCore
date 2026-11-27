-- WX14-CB05 幻獣　オカピ
-- 【常】：このシグニのパワーはあなたのセンタールリグのレベル１につき＋3000される。
-- 【常】：このシグニのパワーが15000以上であるかぎり、このシグニは【ランサー】を得る。
-- 【自】：あなたのライフクロス１枚がクラッシュされたとき、このシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e) local lc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LRIG,0,nil):GetFirst() return 3000*(lc and lc:GetLevel() or 0) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_LANCER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) return e:GetHandler():GetPower()>=15000 end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_CRUSHED)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e3:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.Banish(h) end
  end)
  c:RegisterEffect(e3)
end
