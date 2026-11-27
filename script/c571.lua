-- WX15-032 矜持の豪魔　オダノブ
-- 【ライズ】あなたの＜武勇＞のシグニ１体の上に置く
-- 【常】：このシグニは中央のシグニゾーンにあるかぎり、【トリプルクラッシュ】を得る。
-- 【出】：このシグニのパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。②あなたのデッキから＜武勇＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddRise(c,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BUYU)) end)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_TRIPLE_CRUSH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsInZone("signi_center") end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=e:GetHandler():GetPower() end,tp,0,LOCATION_SZONE,1,1,nil)
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
    if e:GetLabel()==1 then aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BUYU)) end,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=10000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
end
