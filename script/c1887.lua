-- WX01-085 ＦＲＥＥＺＥ
-- 対戦相手のすべてのシグニをダウンし凍結する。（それらは次のアップフェイズにアップしない）
-- ライフバースト：対戦相手のシグニを２体まで対象とし、それらをダウンし凍結する。（それらは次のアップフェイズにアップしない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do
      Duel.Down(tc)
      Duel.Freeze(tc)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  -- 이미 다운이어도 고를 수 있다(FAQ 3)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e2:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then
        Duel.Down(tc)
        Duel.Freeze(tc)
      end
    end
  end)
  c:RegisterEffect(e2)
end
