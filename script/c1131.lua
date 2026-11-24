-- WD04-011 幻獣　ビグタット
-- 【出】：ターン終了時まで、あなたのすべてのシグニのパワーを＋2000する。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  -- 처리할 때 장에 있는 시그니만(자기 포함). 뒤에 나온 시그니는 오르지 않는다(FAQ 5)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
      aux.AddPower(e,tc,2000)  -- [まで] ターン終了時まで
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
