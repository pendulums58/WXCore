-- WX02-019 クロス・ライフ・クロス
-- あなたのライフクロス１枚を手札に加える。そうした場合、手札を１枚ライフクロスに加える。（ライフクロスのカードを移動させる場合は上から順番に加えたり減らしたりする）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 맨 위 1장. 0장이면 뒷부분은 없다(FAQ 1·3). 같은 카드를 되돌려도 된다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetLifetopGroup(tp,1):GetFirst()
    if not (x and Duel.SendToHand(x)>0) then return end
    local h=Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil),1,1)
    if h:GetCount()>0 then Duel.SendToLife(h) end
  end)
  c:RegisterEffect(e1)
end
