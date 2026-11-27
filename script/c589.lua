-- WX16-032 羅菌姫　インフル
-- 【常】：このシグニのパワーは対戦相手の場にある【ウィルス】１つにつき＋1000される。
-- 【自】：このシグニがアタックしたとき、ターン終了時まで、対戦相手の感染状態のすべてのシグニのパワーを－5000する。
-- 【出】：対戦相手のシグニゾーン１つに【ウィルス】１つを置く。
-- ライフバースト：対戦相手の感染状態のシグニ１体を対象とし、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e) return 1000*(function(p) local n=0 for _,z in ipairs(Duel.GetSigniZones(1-p)) do if Duel.HasVirus(z) then n=n+1 end end return n end)(e:GetHandlerPlayer()) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsInfected() end,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,-5000) end  -- [まで]
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetOperation(function(e,tp)
    for _=1,1 do
      local zones={}
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if not Duel.HasVirus(z) then zones[#zones+1]=z end end
      if #zones==0 then break end
      local z=Duel.SelectZone(tp,zones)
      if not z then break end
      Duel.PlaceVirus(z)
    end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsInfected() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e4)
end
