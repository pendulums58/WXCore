-- WD10-011 轟砲　コック
-- 《クロスアイコン》《弩砲　ヘッケラ》の左
-- 【クロス出】：対戦相手のパワー8000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,1196,CROSS_LEFT)
  -- 나왔을 때 크로스 상태여야 발동한다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e) return e:GetHandler():IsCross() end)
  e1:SetTarget(aux.BanishPowerTarget(8000))
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and s.filter(tc) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
function s.filter(c) return c:IsSigni() and c:GetPower()<=8000 end
