-- WX19-045 羅菌　ポレン
-- 【起】《アタックフェイズアイコン》手札からこのカードを捨てる：対戦相手の場にある【ウィルス】の合計が２つになるように、対戦相手のシグニゾーンに【ウィルス】を置く。この能力はあなたのセンタールリグが＜ナナシ＞の場合にしか使用できない。
-- （【ウィルス】はシグニゾーン１つにつき１つまでしか置けない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_HAND)
  e1:SetTiming(TIMING_ATTACK)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_HAND) end
    Duel.SendToTrash(e:GetHandler(),REASON_COST+REASON_DISCARD)
  end)
  e1:SetCondition(function(e,tp) local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_NANASHI) end)
  e1:SetOperation(function(e,tp)
    local function cnt() local n=0 for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if Duel.HasVirus(z) then n=n+1 end end return n end
    while cnt()<2 do
      local zones={}
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if not Duel.HasVirus(z) then zones[#zones+1]=z end end
      if #zones==0 then break end
      Duel.PlaceVirus(Duel.SelectZone(tp,zones))
    end
  end)
  c:RegisterEffect(e1)
end
