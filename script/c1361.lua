-- WD22-038-UG 惨之遊魔　†スロット†
-- 【常】：あなたのトラッシュにカードが１５枚以上あるかぎり、このシグニの基本パワーは12000になる。
-- 【出】：あなたのデッキの上からカードを５枚トラッシュに置く。その後、あなたのトラッシュにカードが２０枚以上ある場合、あなたのトラッシュからレベル２以下の黒のシグニ１枚を対象とし、それをダウン状態で場に出す。
-- ライフバースト：あなたのデッキの上からカードを３枚トラッシュに置く。その後、あなたのトラッシュから無色ではないシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,12000,function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=15 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    if Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil):GetCount()<20 then return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) and x:IsLevelBetween(0,2) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc and Duel.PutOnField(tc,tp) then Duel.Down(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetColor()~=0 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
end
