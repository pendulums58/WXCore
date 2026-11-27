-- WX13-057 幻蟲　オニヤンマ
-- 【常】：このシグニが中央のシグニゾーンにあるかぎり、このシグニは「【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－5000する。」を得る。
-- 【出】：対戦相手の場にある【チャーム】１枚を対象とし、それをトラッシュに置く。この方法で【チャーム】１枚がトラッシュに置かれなかった場合、このシグニを場からトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  g:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-5000) end
  end)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SIGNI,0)
  e1:SetTarget(function(e,x) return x==e:GetHandler() and x:IsInZone("signi_center") end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local cg=Group.CreateGroup()
    for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetCharm()~=nil end,tp,0,LOCATION_SZONE,nil):Iter() do cg:AddCard(x:GetCharm()) end
    local n=0
    if cg:GetCount()>=1 then n=Duel.SendToTrash(Duel.SelectCards(tp,cg,1,1),REASON_EFFECT) end
    local h=e:GetHandler()
    if n<1 and h:IsLocation(LOCATION_SZONE) then Duel.SendToTrash(h,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
