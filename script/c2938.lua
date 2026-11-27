-- WX17-054 炎纏の天牛　グガランネ
-- 【自】：このシグニがライズされたとき、ターン終了時まで、あなたのすべてのシグニのパワーを＋2000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_RISEN)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,tc,2000) end  -- [まで]
  end)
  c:RegisterEffect(e1)
end
