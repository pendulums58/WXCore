-- WDK10-001 爆掃の閻魔　ウリス
-- 【出】：あなたのトラッシュから＜龍獣＞のシグニを２枚まで対象とし、それらを手札に加える。
-- 【起】《ターン１回》トラッシュにあるカード１枚をゲームから除外する：対戦相手は、自分のエナゾーンからカード１枚を対象とし、手札を１枚捨てないかぎりそれをトラッシュに置く。
-- 【起】《ゲーム１回》ディスペア《コインアイコン》：あなたのトラッシュから＜龍獣＞のシグニ１枚を対象とし、あなたのライフクロスが０枚の場合、それをライフクロスに加える。
local s,id=GetID()
s.ryu=aux.ClassFilter(0,RACE_RYUJU)  -- ＜龍獣＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.ryu,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil)
    if chk==0 then return g:GetCount()>0 end
    Duel.Exclude(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  -- 고르는 것도 버리는 것도 상대
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(1-tp,nil,1-tp,LOCATION_ENA,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local g=Duel.SelectDiscard(1-tp,0,1)
    if g:GetCount()>0 and Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD)>0 then return end
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1,true)
  e3:SetCoinCost(1)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.ryu,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if Duel.GetLifetopGroup(tp,1):GetCount()==0 and tc and tc:IsRelateToEffect(e) then Duel.SendToLife(tc) end
  end)
  c:RegisterEffect(e3)
end
