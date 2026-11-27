-- WX19-080 羅菌　ハクセン
-- 【出】：あなたのトラッシュからそれぞれレベルの異なる＜微菌＞のシグニ３枚をデッキに加えてシャッフルする。そうした場合、対戦相手のシグニゾーン１つに【ウィルス】１つを置く。
-- （【ウィルス】はシグニゾーン１つにつき１つまでしか置けない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKIN)) end,tp,LOCATION_TRASH,0,nil)
    Duel.SetSelectCheck(function(sg) return sg:GetCount()==0 or (sg:GetCount()==3 and aux.DistinctLevels(sg)) end)
    local pick=Duel.SelectCards(tp,g,0,3)
    if pick:GetCount()<3 then return end
    Duel.SendToDeckShuffle(pick,tp)
    for _=1,1 do
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
