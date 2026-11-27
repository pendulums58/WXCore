-- WX21-021 羅星姫　リゲルル
-- 【常】：このシグニはすべてのクラスを持つ。
-- 【自】：レゾナの出現条件のために、このシグニが場からトラッシュに置かれたとき、あなたのデッキからカード１枚を探して手札に加え、デッキをシャッフルする。
-- 【起】《アタックフェイズアイコン》あなたのトラッシュにある《羅星姫　リゲルル》４枚をゲームから除外する：対戦相手のシグニ１体を対象とし、それをトラッシュに置く。この能力はこのカードがトラッシュにある場合にしか使用できない。
-- ライフバースト：あなたのデッキからカード１枚を探して手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 「すべてのクラスを持つ」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return r&REASON_RESONA~=0 and e:GetHandler():IsPreviousLocation(LOCATION_SZONE) end)
  e1:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil),0,1)
    if x:GetCount()>0 then Duel.SendToHand(x) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_TRASH)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsCardName(id) end,tp,LOCATION_TRASH,0,nil)
    if chk==0 then return g:GetCount()>=4 end
    Duel.Exclude(Duel.SelectCards(tp,g,4,4))
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil),0,1)
    if x:GetCount()>0 then Duel.SendToHand(x) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
