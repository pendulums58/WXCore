-- WXK01-072 コードライド　シロパト
-- 【起】《ターン１回》《赤》《赤》：対戦相手のパワー12000以下のシグニ１体を対象とし、あなたの場にドライブ状態のシグニがある場合、それをバニッシュする。
-- （ルリグが乗っているシグニはドライブ状態である）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetEnaCost("{R}{R}")
  e1:SetTarget(aux.BanishPowerTarget(12000))
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if tc:GetPower()<=12000 and Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsDrive() end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e1)
end
