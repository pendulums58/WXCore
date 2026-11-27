-- WX09-022 原槍　ラナジェ
-- 【常】：あなたのトラッシュにカード名に《エナジェ》を含むカードがあるかぎり、対戦相手のシグニがこのシグニによってバニッシュされる場合、エナゾーンに置かれる代わりにトラッシュに置かれる。（バトルによるバニッシュを含む）
-- 【起】《白》《赤》《青》《緑》《黒》：対戦相手のシグニを２体まで対象とし、それらをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 배틀·이 시그니의 능력(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_KILL_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"エナジェ") end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>0 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{W}{R}{U}{G}{B}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e2)
end
