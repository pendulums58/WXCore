-- WXK08-075 炎魔の史実　リエル
-- 【出】《ビートアイコン》［４枚以下］他のシグニ１体を【ビート】にする：次のあなたのターンまで、このシグニのパワーは＋8000される。
-- （この能力はあなたの【ビート】が４枚以下であるかぎり有効になる。コストの支払いで【ビート】が５枚になっても発動する）
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
    if chk==0 then return g:GetCount()>=1 end
    Duel.Beat(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if not h:IsLocation(LOCATION_SZONE) then return end
    -- [まで] 次のあなたのターンまで
    local e1=Effect.CreateEffect(h)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_POWER)
    e1:SetValue(8000)
    e1:SetReset(RESET_MY_TURN)
    h:GrantEffect(e1)
  end)
  c:RegisterEffect(e1)
end
