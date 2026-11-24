-- WD06-011 幻水　リュウグウ
-- 【起】《ダウン》：あなたのライフクロス１枚を手札に加える。そうした場合、あなたのデッキの一番上のカードをライフクロスに加える。
-- ライフバースト：あなたのライフクロス１枚を手札に加える。そうした場合、手札１枚をライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp)
    if s.lifetohand(tp) then Duel.SendToLife(Duel.GetDecktopGroup(tp,1)) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    if not s.lifetohand(tp) then return end
    local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil),1,1)
    if g:GetCount()>0 then Duel.SendToLife(g) end
  end)
  c:RegisterEffect(e2)
end
-- 라이프 클로스 맨 위 1장을 패에. 라이프 클로스가 없으면 「そうした場合」 뒤도 하지 않는다(FAQ 1)
function s.lifetohand(tp)
  local g=Duel.GetLifetopGroup(tp,1)
  return g:GetCount()>0 and Duel.SendToHand(g)>0
end
