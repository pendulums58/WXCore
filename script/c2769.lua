-- WX15-040 羅菌姫　オイゴナ
-- 【自】：このシグニがバニッシュされたとき、対戦相手の場にある【ウィルス】２つを取り除いてもよい。そうした場合、このシグニをエナゾーンから場に出す。
-- 【出】：対戦相手の感染状態のシグニ１体を対象とし、ターン終了時まで、それのパワーを－10000する。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－8000する。それが感染状態の場合、代わりに－12000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
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
    local zones=0
    for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if Duel.HasVirus(z) then zones=zones+1 end end
    if zones<2 or not Duel.SelectYesNo(tp) or remove_virus(2)<2 then return end
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_ENA) then Duel.PutOnField(h,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsInfected() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-10000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,tc:IsInfected() and -12000 or -8000) end
  end)  -- [まで]
  c:RegisterEffect(e3)
end
