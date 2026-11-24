-- WD20-008 母性本能
-- このカードはあなたがこのターンにアーツを使用していた場合、使用できない。
-- 各プレイヤーは自分のデッキの上からカードを３枚までエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) return Duel.GetArtsUsedCount(tp)==0 end)
  -- 각자 정하고(턴 플레이어부터) 동시에 놓는다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local p,g=Duel.GetTurnPlayer(),Group.CreateGroup()
    for _,x in ipairs{p,1-p} do
      local max=math.min(3,Duel.GetMatchingGroup(nil,x,LOCATION_MDECK,0,nil):GetCount())
      for c in Duel.GetDecktopGroup(x,Duel.AnnounceNumber(x,0,max)):Iter() do g:AddCard(c) end
    end
    if g:GetCount()>0 then Duel.SendToEna(g) end
  end)
  c:RegisterEffect(e1)
end
