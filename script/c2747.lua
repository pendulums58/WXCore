-- WX15-004 ナナシ　其ノ四ノ別
-- 【常】：対戦相手の感染状態のシグニのパワーを－1000する。
-- 【自】：あなたのメインフェイズ開始時、対戦相手のシグニゾーン１つに【ウィルス】1つを置く。
-- 【起】ブラインド《コインアイコン》《コインアイコン》：次の対戦相手のターンの間、あなたのシグニは【シャドウ】を得る。
-- （【シャドウ】を持つあなたのシグニは対戦相手によって対象にされない）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(0,LOCATION_SZONE)
  e1:SetTarget(function(e,x) return x:IsInfected() end)
  e1:SetValue(-1000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_PHASE_START+PHASE_MAIN)
  e2:SetRange(LOCATION_LRIG)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e2:SetOperation(function(e,tp)
    for _=1,1 do
      local zones={}
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if not Duel.HasVirus(z) then zones[#zones+1]=z end end
      if #zones==0 then break end
      local z=Duel.SelectZone(tp,zones)
      if not z then break end
      Duel.PlaceVirus(z)
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCoinCost(2)
  e3:SetOperation(function(e,tp)
    -- [の間] 「次の対戦相手のターンの間」 그때 장에 있는 시그니 모두(나중에 나온 것도. FAQ 4)
    local now=Duel.GetTurnCount()
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SHADOW)
    e1:SetTargetRange(LOCATION_SZONE,0)
    e1:SetTarget(function(e2,x) return x:IsSigni() end)
    e1:SetCondition(function() return Duel.GetTurnCount()==now+1 end)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e3)
end
