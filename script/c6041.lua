-- WXEX1-07 遊月・四篝
-- 【自】：あなたのアタックフェイズ開始時、対戦相手は、自分のエナゾーンからカード１枚を対象とし、対戦相手のエナゾーンにカードが５枚以上ある場合、それをトラッシュに置く。
-- 【出】：対戦相手は色１つを宣言する。対戦相手は自分のエナゾーンから宣言した色ではない色を持つすべてのカードをトラッシュに置く。
-- 【起】《ターン１回》《コインアイコン》：あなたのライフクロス１枚をクラッシュする。そうした場合、カードを３枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(1-tp,nil,1-tp,LOCATION_ENA,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,0,LOCATION_ENA,nil):GetCount()<5 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local m=Duel.SelectOption(1-tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4))
    local col=({COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_GREEN,COLOR_BLACK})[m+1]
    local g=Duel.GetMatchingGroup(function(x) return x:GetColor()~=0 and not x:IsColor(col) end,tp,0,LOCATION_ENA,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1)
  e3:SetCoinCost(1)
  e3:SetOperation(function(e,tp)
    if Duel.Crush(tp,1):GetCount()>0 then Duel.Draw(tp,3) end
  end)
  c:RegisterEffect(e3)
end
