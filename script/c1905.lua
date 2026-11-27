-- WX02-007 轟炎罪　遊月・参
-- 【起】《赤》：対戦相手のパワー5000以下のシグニ１体を対象とし、それをバニッシュする。
-- 【起】《緑》：ターン終了時まで、あなたのすべてのシグニのパワーを＋5000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_LRIG)
  e1:SetEnaCost("{R}")
  e1:SetTarget(aux.BanishPowerTarget(5000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetEnaCost("{G}")
  -- [まで] 처리할 때 장에 있는 시그니만
  e2:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,tc,5000) end
  end)
  c:RegisterEffect(e2)
end
