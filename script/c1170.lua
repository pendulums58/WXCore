-- WD08-010 コードアンチ　ネビュラ
-- 【起】《黒》《黒》：このシグニをトラッシュから場に出す。（この能力は、このシグニがトラッシュにある場合にしか使用できない）
local s,id=GetID()
function s.initial_effect(c)
  -- 선언할 때 트래시에 있어야 한다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_TRASH)
  e1:SetEnaCost("{B}{B}")
  e1:SetOperation(function(e,tp)
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_TRASH) then Duel.PutOnField(c,tp) end
  end)
  c:RegisterEffect(e1)
end
