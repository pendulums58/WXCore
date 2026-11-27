-- WX02-017 気炎万丈
-- あなたのライフクロス１枚をクラッシュする。そのカードが【ライフバースト】を持つ場合、対戦相手のパワー10000以下のすべてのシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 얻은 라이프 버스트도 친다(FAQ 1). 그 버스트는 처리한 뒤에 발동한다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local x=Duel.Crush(tp,1):GetFirst()
    if not (x and x:IsLifeBurst()) then return end
    local g=Duel.GetMatchingGroup(function(c) return c:IsSigni() and c:GetPower()<=10000 end,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
end
