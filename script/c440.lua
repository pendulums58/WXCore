-- WD05-009 堕落の砲女　メツム
-- 【出】：各プレイヤーは自分のデッキの上からカードを７枚トラッシュに置く。
-- ライフバースト：あなたのトラッシュからカード１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
end
-- 두 플레이어가 동시에 놓는다(FAQ 1): 한 묶음으로 한 번에 옮긴다.
-- 덱이 7장 미만이면 있는 만큼 놓고, 리프레시는 효과가 끝난 뒤 룰 처리로(FAQ 3·4)
function s.op(e,tp)
  local g=Group.CreateGroup()
  for _,p in ipairs({tp,1-tp}) do
    for x in Duel.GetDecktopGroup(p,7):Iter() do g:AddCard(x) end
  end
  if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
end
