-- WDK17-017 舞踏の童話　タウベズ
-- 【出】：対戦相手のトラッシュからレベル１のシグニ１枚を対象とし、あなたのターンの場合、それを傀儡状態であなたの場に出す。
-- （傀儡状態のシグニが場を離れる場合、代わりに持ち主のトラッシュに置かれる）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==1 end,tp,0,LOCATION_TRASH,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    if not (Duel.GetTurnPlayer()==tp) then return end
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_TRASH) then Duel.PutOnField(tc,tp) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
