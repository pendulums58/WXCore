-- WX16-058 戦獣の足柄　スモウグマ
-- 【出】：対戦相手のパワー1000以下のシグニ１体を対象とし、それをバニッシュする。あなたの場に《ライズアイコン》を持つシグニがある場合、代わりに対戦相手のパワー2000以下のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=((Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_SZONE,0,nil):GetCount()>0) and 2000 or 1000) end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
