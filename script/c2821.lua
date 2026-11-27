-- WX15-111 羅菌　ラクチス
-- 【自】：このシグニがバニッシュされたとき、以下の２つから１つを選ぶ。
-- ①対戦相手のすべてのシグニゾーンに【ウィルス】を１つずつ置く。
-- ②ターン終了時まで、対戦相手の感染状態のすべてのシグニのパワーを－5000する。
-- （【ウィルス】と同じシグニゾーンにあるシグニは感染状態である）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetOperation(function(e,tp)
    if Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1]==0 then
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do Duel.PlaceVirus(z) end
    else
      -- [まで]
      for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsInfected() end,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,-5000) end
    end
  end)
  c:RegisterEffect(e1)
end
