-- WX02-024 羅植姫　ゴーシュ・アグネス
-- 【出】《緑》：対戦相手のパワー15000以上のシグニ１体を対象とし、それをバニッシュする。
-- 【起】アップ状態の＜植物＞のシグニ１体をダウンする：あなたのデッキの一番上のカードをエナゾーンに置く。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のパワー10000以上のシグニ１体を対象とし、それをバニッシュする。②あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{G}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=15000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_SHOKUBUTSU)) end)(x) and x:IsUp() end,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return g:GetCount()>0 end
    Duel.Down(Duel.SelectCards(tp,g,1,1):GetFirst())
  end)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1)))
    if e:GetLabel()==0 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=10000 end,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e3:SetOperation(function(e,tp)
    if e:GetLabel()==1 then
      Duel.EnaCharge(tp,1)
      return
    end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
end
