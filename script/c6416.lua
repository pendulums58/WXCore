-- WXK03-042 幻怪　レーシー
-- 【自】：あなたがアーツを使用したとき、このシグニをあなたの他のシグニゾーン１つに配置してもよい。そのシグニゾーンにシグニがある場合、そこに配置する代わりにこのシグニとそのシグニの場所を入れ替える。
-- 【自】《ターン１回》：場にあるこのシグニが他のシグニゾーンに移動したとき、あなたのシグニ１体を対象とし、ターン終了時まで、それのパワーを＋2000し、それは「【常】：このシグニは対戦相手のシグニの効果を受けない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_USE_CARD)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp and eg:GetFirst():IsType(TYPE_ARTS) end)
  e1:SetOperation(function(e,tp,eg)
    -- 옮기지 않아도 된다(FAQ 1)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) then return end
    local zs={}
    for _,z in ipairs(Duel.GetSigniZones(tp)) do if z~=h:GetZone() then zs[#zs+1]=z end end
    local z=Duel.SelectZone(tp,zs)
    if not z then return end
    local o=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetZone()==z end,tp,LOCATION_SZONE,0,nil):GetFirst()
    if o then Duel.SwapSigni(h,o) else Duel.MoveSigni(h,z) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_SIGNI_MOVED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg) return eg:IsContains(e:GetHandler()) end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,2000)
      -- [まで] ターン終了時まで
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_IMMUNE)
      e1:SetValue(function(e2,sc,sp) return sp~=e2:GetHandlerPlayer() and sc:IsSigni() end)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
    end
  end)
  c:RegisterEffect(e2)
end
