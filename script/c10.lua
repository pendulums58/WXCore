-- WX09-Re10 羅石　ミスリル
-- 【出】：手札を１枚捨てる。
-- 【常】：あなたのターンの間、このシグニの基本パワーは18000になる。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e1)
  -- [の間] 【常】
  aux.BasePower(c,18000,function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
