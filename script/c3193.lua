-- WX21-030 羅菌染姫　ペズト
-- 【自】：【ウィルス】１つが対戦相手の場に置かれるか対戦相手の場から取り除かれたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－5000する。
-- 【起】《ターン１回》《メインフェイズアイコン》《アタックフェイズアイコン》《黒×0》：対戦相手のシグニゾーン１つに【ウィルス】１つを置くか、対戦相手の場にある【ウィルス】１つを取り除く。
-- 【起】《アタックフェイズアイコン》手札からこのカードを捨て、対戦相手の場にある【ウィルス】３つを取り除く：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－10000する。
-- ライフバースト：あなたのトラッシュから＜微菌＞のシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_VIRUS_PLACED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep~=tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-5000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,0))
  e2:SetCode(EVENT_VIRUS_REMOVED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg,ep) return ep~=tp end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-5000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,1))
  e3:SetRange(LOCATION_SZONE)
  e3:SetCountLimit(1)
  e3:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e3:SetOperation(function(e,tp)
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
    -- 예 = 둔다, 아니오 = 치운다
    if Duel.SelectYesNo(tp) then
    for _=1,1 do
      local zones={}
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if not Duel.HasVirus(z) then zones[#zones+1]=z end end
      if #zones==0 then break end
      local z=Duel.SelectZone(tp,zones)
      if not z then break end
      Duel.PlaceVirus(z)
    end
    else remove_virus(1) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetDescription(aux.Ability(id,2))
  e4:SetRange(LOCATION_HAND)
  e4:SetTiming(TIMING_ATTACK)
  e4:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local zones={}
    for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if Duel.HasVirus(z) then zones[#zones+1]=z end end
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_HAND) and #zones>=3 end
    Duel.SendToTrash(e:GetHandler(),REASON_COST+REASON_DISCARD)
    for _,z in ipairs(zones) do Duel.RemoveVirus(z) end
  end)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-10000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e4)
  local e5=Effect.CreateEffect(c)
  e5:SetType(EFFECT_TYPE_LIFEBURST)
  e5:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKIN)) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e5:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e5)
end
