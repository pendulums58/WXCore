-- WX11-006 焦熱の閻魔　ウリス
-- 【出】：あなたのデッキからカードを３枚まで探してトラッシュに置き、デッキをシャッフルする。
-- 【起】《ターン１回》エクシード１：＜悪魔＞のシグニ１体を対象とし、それをバニッシュする。そうした場合、カードを２枚引く。
-- 【起】《ターン１回》《アタックフェイズアイコン》エクシード１：あなたのトラッシュから＜悪魔＞のシグニ１枚を対象とし、手札からカードを１枚捨てる。そうした場合、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=aux.Search(tp,nil,3)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetExceedCost(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.Banish(tc)>0 then Duel.Draw(tp,2) end end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1)
  e3:SetExceedCost(1)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) or aux.Discard(tp,1)==0 then return end
    Duel.PutOnField(tc,tp)
  end)
  c:RegisterEffect(e3)
end
