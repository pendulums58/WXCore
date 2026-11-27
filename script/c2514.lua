-- WX11-067 羅石　アクアオラ
-- 《クロスアイコン》《羅石　ロズオラ》の左
-- 【クロス常】：このシグニの基本パワーは5000になる。
-- 【クロス出】：対戦相手のパワー3000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2512,CROSS_LEFT)
  -- [の間] 【クロス常】
  aux.BasePower(c,5000,function(e) return e:GetHandler():IsCross() end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,2))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e) return e:GetHandler():IsCross() end)
  e1:SetTarget(aux.BanishPowerTarget(3000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
end
