-- WX03-031 幻獣　ベイア
-- 【自】：あなたのシグニが対戦相手のライフクロス１枚をクラッシュしたとき、あなたのデッキの一番上のカードをエナゾーンに置く。
-- 【出】：ターン終了時まで、あなたのすべてのシグニのパワーを＋5000する。
local s,id=GetID()
function s.initial_effect(c)
  -- 【ランサー】로도, 2장이면 두 번, 여러 체면 각각(FAQ 1~3)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep)
    local x=Duel.GetCrusher()
    return ep~=tp and x and x:IsSigni() and x:GetControler()==tp
  end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  -- [まで] 처리할 때 장에 있는 시그니만. 떠나도 남는다(FAQ 4)
  e2:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,tc,5000) end
  end)
  c:RegisterEffect(e2)
end
