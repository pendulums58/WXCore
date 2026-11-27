-- WX12-028 幻竜　ヴェロキラ
-- 【常】：あなたの場に他の＜龍獣＞のシグニがあるかぎり、このシグニは「【自】：このシグニが対戦相手のライフクロス１枚をクラッシュしたとき、対戦相手のエナゾーンからカード１枚を対象とし、それをトラッシュに置く。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,0))
  g:SetCode(EVENT_CRUSHED)
  g:SetRange(LOCATION_SZONE)
  g:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetCrusher()==e:GetHandler() end)
  g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_ENA,1,1,nil)
  end)
  g:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SIGNI,0)
  e1:SetTarget(function(e,x) return x==e:GetHandler() and Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,x):GetCount()>0 end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
end
