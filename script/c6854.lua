-- WXK08-068 炎魔の尾火　アイトワラス
-- 【出】《ビートアイコン》［４枚以下］このシグニと他のシグニ１体を【ビート】にする：対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- （この能力はあなたの【ビート】が４枚以下であるかぎり有効になる。コストの支払いで【ビート】が５枚以上になっても発動する）
-- （【ビート】はターン終了時まであなたが持ち、その後トラッシュに置かれる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(aux.BeatCon(function(g) return g:GetCount()<=4 end))
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x~=e:GetHandler() end,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return g:GetCount()>=1 and e:GetHandler():IsLocation(LOCATION_SZONE) end
    Duel.Beat(Duel.SelectCards(tp,g,1,1),REASON_COST)
    Duel.Beat(e:GetHandler(),REASON_COST)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.Banish(tc)
    end
  end)
  c:RegisterEffect(e1)
end
