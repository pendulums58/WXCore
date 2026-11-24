-- WD15-024 烈情の割裂
-- 各プレイヤーは自分のエナゾーンのカードが４枚になるように、エナゾーンからカードをトラッシュに置く。（エナゾーンのカードが４枚以下のプレイヤーは、この効果の影響を受けない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local tr=Group.CreateGroup()
    for _,p in ipairs({Duel.GetTurnPlayer(),1-Duel.GetTurnPlayer()}) do
      local g=Duel.GetMatchingGroup(nil,p,LOCATION_ENA,0,nil)
      local n=g:GetCount()-4
      if n>0 then
        for x in Duel.SelectCards(p,g,n,n):Iter() do tr:AddCard(x) end
      end
    end
    Duel.SendToTrash(tr,REASON_EFFECT)
  end)
  c:RegisterEffect(e1)
end
