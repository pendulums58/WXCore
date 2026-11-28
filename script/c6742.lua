-- WXK07-044 羅菌　ビタミンD
-- 【常】：このシグニは中央のシグニゾーンにあるかぎり、「【自】：このシグニがアタックしたとき、対戦相手のパワー7000のシグニ１体を対象とし、それをバニッシュする。このシグニに【チャーム】が付いている場合、代わりに対戦相手のパワー12000以上のシグニ１体を対象とし、それをバニッシュする。」を得る。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のパワー12000以上のシグニ１体を対象とし、それをバニッシュする。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Stringid(id,2))
  g:SetCode(EVENT_ATTACK)
  g:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local ch=h:GetCharm()~=nil
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (ch and x:GetPower()>=12000 or not ch and x:GetPower()==7000) end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsInZone("signi_center") end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==1 then Duel.EnaCharge(tp,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e9)
end
