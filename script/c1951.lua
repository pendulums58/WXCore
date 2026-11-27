-- WX02-071 コードアンチ　デリー
-- 【起】《黒》《無》：このシグニをトラッシュから場に出す。（この能力は、このシグニがトラッシュにある場合にしか使用できない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_TRASH)
  e1:SetEnaCost("{B}{C}")
  -- 쓸 때 트래시에 있어야 한다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) then Duel.PutOnField(h,tp) end
  end)
  c:RegisterEffect(e1)
end
