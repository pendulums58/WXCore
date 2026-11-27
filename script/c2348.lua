-- WX09-024 天左の書記　メタトロン
-- 《クロスアイコン》 《天右の書記　サンダルフォン》の左
-- 【クロス常】：このシグニの基本パワーは8000になる。
-- 【クロス自】：このシグニが《ヘブン》したとき、カードを１枚引く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2363,CROSS_LEFT)
  -- [の間] 【クロス常】
  aux.BasePower(c,8000,function(e) return e:GetHandler():IsCross() end)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_HEAVEN)
  e2:SetRange(LOCATION_SZONE)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
end
