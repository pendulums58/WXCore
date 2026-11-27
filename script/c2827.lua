-- WX15-117 羅菌　アクネス
-- 【起】《ダウン》：対戦相手の場にある【ウィルス】１つを取り除く。そうした場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp)
    local function remove_virus(mx)
      local zones={}
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if Duel.HasVirus(z) then zones[#zones+1]=z end end
      local n=#zones>0 and Duel.AnnounceNumber(tp,0,math.min(#zones,mx or #zones)) or 0
      local removed=0
      for _=1,n do
        local left={}
        for _,z in ipairs(zones) do if Duel.HasVirus(z) then left[#left+1]=z end end
        local z=Duel.SelectZone(tp,left)
        if z and Duel.RemoveVirus(z) then removed=removed+1 end
      end
      return removed
    end
    if remove_virus(1)>0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
