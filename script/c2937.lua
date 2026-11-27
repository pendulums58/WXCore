-- WX17-053 復讐の牛飼　イシュタロ
-- 【自】：このシグニがアタックしたとき、ターン終了時まで、このシグニのパワーを《ライズアイコン》を持つあなたのシグニ１体につき＋3000する。
-- 【自】：このシグニがアタックしたとき、このシグニの正面のシグニ１体を対象とし、あなたの場に《ライズアイコン》を持つシグニが２体ある場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local n=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_SZONE,0,nil):GetCount()
    if n>0 and h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,3000*n) end  -- [まで]
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local f=Duel.GetFrontZone(e:GetHandler():GetZone())
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetZone()==f end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_SZONE,0,nil):GetCount()>=2 then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e2)
end
