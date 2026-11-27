-- WX16-046 羅菌　アオカビ
-- 【常】：このシグニのパワーは対戦相手の場にある【ウィルス】１つにつき＋1000される。
-- 【自】：対戦相手のターン終了時、対戦相手の感染状態のシグニ１体を対象とし、それをバニッシュする。（【ウィルス】と同じシグニゾーンにあるシグニは感染状態である）
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手のシグニゾーン２つまでに【ウィルス】を１つずつ置く。
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
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TURN_END)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsInfected() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e3:SetOperation(function(e,tp)
    if e:GetLabel()==0 then Duel.Draw(tp,1) return end
    for _=1,2 do
      local zones={}
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if not Duel.HasVirus(z) then zones[#zones+1]=z end end
      if #zones==0 then break end
      local z=Duel.SelectZone(tp,zones)
      if not z then break end
      Duel.PlaceVirus(z)
    end
  end)
  c:RegisterEffect(e3)
end
