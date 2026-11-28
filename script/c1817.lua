-- WDK17-013 舞踏の童話　リンツ
-- 【出】：対戦相手のトラッシュからレベル３以下のシグニ１枚を対象とし、あなたのターンの場合、それを傀儡状態であなたの場に出す。
-- （傀儡状態のシグニが場を離れる場合、代わりに持ち主のトラッシュに置かれる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  -- 상대 턴이면 대상만 고르고 아무 일도 없다
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_TRASH,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    if not (Duel.GetTurnPlayer()==tp) then return end
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_TRASH) then Duel.PutOnField(tc,tp) end
    end
  end)
  c:RegisterEffect(e1)
end
