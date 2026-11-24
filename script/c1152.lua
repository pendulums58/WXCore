-- WD07-002 ペイル/メイデン　イオナ
-- 【常】：対戦相手のシグニは可能ならばアタックしなければならない。
-- 【出】《黒》：ターン終了時まで、対戦相手のすべてのシグニのパワーを－2000する。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_MUST_ATTACK)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(0,LOCATION_SIGNI)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{B}")
  e2:SetOperation(function(e,tp)
    -- [まで] 처리할 때 장에 있는 시그니만(FAQ 1)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SIGNI,nil):Iter() do
      aux.AddPower(e,tc,-2000)
    end
  end)
  c:RegisterEffect(e2)
end
