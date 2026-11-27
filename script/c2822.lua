-- WX15-112 羅菌　プレビス
-- 【自】：このシグニがバニッシュされたとき、対戦相手のシグニゾーン２つまでに【ウィルス】を１つずつ置く。
-- （【ウィルス】はシグニゾーン１つにつき１つまでしか置けない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetOperation(function(e,tp)
    for _=1,2 do
      local zones={}
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if not Duel.HasVirus(z) then zones[#zones+1]=z end end
      if #zones==0 then break end
      local z=Duel.SelectZone(tp,zones)
      if not z then break end
      Duel.PlaceVirus(z)
    end
  end)
  c:RegisterEffect(e1)
end
