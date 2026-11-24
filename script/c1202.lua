-- WD10-015 小砲　グレネド
-- 《クロスアイコン》《爆砲　スタン》の右
-- 【クロス常】：このシグニの基本パワーは5000になる。
-- 【クロス自】：このシグニが《ヘブン》したとき、対戦相手のパワー2000以下のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,1200,CROSS_RIGHT)
  -- [の間] 【常】
  aux.BasePower(c,5000,function(e) return e:GetHandler():IsCross() end)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_HEAVEN)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTarget(aux.BanishPowerTarget(2000))
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and s.filter(tc) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e3)
end
function s.filter(c) return c:IsSigni() and c:GetPower()<=2000 end
