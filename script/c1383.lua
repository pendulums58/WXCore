-- WD23-026-E 幻水　エレノズ
-- 【起】《ダウン》：対戦相手はライフクロス１枚をトラッシュに置く。そうした場合、対戦相手はデッキの一番上のカードをライフクロスに加える。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetLifetopGroup(1-tp,1)
    if g:GetCount()>0 and Duel.SendToTrash(g,REASON_EFFECT)>0 then Duel.SendToLife(Duel.GetDecktopGroup(1-tp,1)) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
