-- WX16-026 竜将の独眼　ダテマサ
-- 【自】：《ライズアイコン》を持つあなたのシグニ１体が場に出たとき、以下の３つから１つを選ぶ。①ターン終了時まで、このシグニは「【常】：バニッシュされない。」を得る。②対戦相手のパワー7000以下のシグニ１体を対象とし、それをバニッシュする。③あなたのシグニ１体を対象とし、ターン終了時まで、それのパワーを＋5000する。
-- 【起】《アタックフェイズアイコン》《赤×0》：あなたの手札から《ライズアイコン》を持つシグニ１枚を場に出す。
-- ライフバースト：あなたのトラッシュから《ライズアイコン》を持つシグニと《武勇》のシグニをそれぞれ１枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:HasRiseIcon() end)
  e1:SetOperation(function(e,tp)
    local m=Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))[1]
    local h=e:GetHandler()
    if m==0 then
      if h:IsLocation(LOCATION_SZONE) then
        local tc=h
    local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_BANISH)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
      end
    elseif m==1 then
      local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=7000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    else
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
      if tc then aux.AddPower(e,tc,5000) end  -- [まで]
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_HAND,0,nil),1,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_TRASH,0,0,1,nil)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BUYU)) end,tp,LOCATION_TRASH,0,0,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e3)
end
