-- WX17-002 アロス・ピルルク　Ｎ
-- 【常】：このルリグはカード名に《アロス》を含むルリグにしかグロウできない
-- 【出】：カードを２枚引く。
-- 【起】《ターン１回》手札を２枚捨てる：対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- 【起】《ターン１回》《アタックフェイズアイコン》手札から＜凶蟲＞のシグニを３枚捨てる：対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- 【起】ピーピング《コインアイコン》《コインアイコン》：対戦相手の手札を見る。その後、数字１つを宣言し、その数字と同じレベルの無色ではないシグニをすべて捨てさせる。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 「《アロス》を含むルリグにしかグロウできない」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCost(aux.DiscardCost(2,nil))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetCost(aux.DiscardCost(3,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KYOUCHU)) end))
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetDescription(aux.Ability(id,4))
  e4:SetRange(LOCATION_LRIG)
  e4:SetCoinCost(2)
  e4:SetOperation(function(e,tp)
    local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if h:GetCount()>0 then Duel.ConfirmCards(tp,h) end
    local n=Duel.AnnounceNumber(tp,0,5)
    local g=h:Filter(function(x) return x:IsSigni() and x:GetColor()~=0 and x:GetLevel()==n end,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD) end
  end)
  c:RegisterEffect(e4)
end
