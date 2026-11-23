-- WD03-006 ピーピング・アナライズ
-- 数字１つを宣言する。その後、対戦相手の手札を見て、宣言した数字と同じレベルのシグニをすべて捨てさせる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 시그니 레벨은 0~5
function s.op(e,tp)
  local n=Duel.AnnounceNumber(tp,0,5)
  local hand=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
  Duel.ConfirmCards(tp,hand)
  local g=hand:Filter(function(x) return x:IsSigni() and x:GetLevel()==n end,nil)
  if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD) end
end
