-- WX20-030 羅菌　マイプラ
-- 【自】：あなたのターン終了時、対戦相手の場に【ウィルス】がない場合、このシグニを場からトラッシュに置く。
-- 【起】《アタックフェイズアイコン》対戦相手の場にある【ウィルス】１つを取り除く：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－4000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and (function(p) local n=0 for _,z in ipairs(Duel.GetSigniZones(1-p)) do if Duel.HasVirus(z) then n=n+1 end end return n end)(tp)==0 end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.SendToTrash(h,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local zones={}
    for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if Duel.HasVirus(z) then zones[#zones+1]=z end end
    if chk==0 then return #zones>0 end
    Duel.RemoveVirus(Duel.SelectZone(tp,zones))
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-4000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e2)
end
