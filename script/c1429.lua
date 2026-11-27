-- WX15-036 大幻蟲　§オタガメ§
-- 【自】：このカードが手札からトラッシュに置かれたとき、このカードをトラッシュから場に出してもよい。
-- 【出】：対戦相手のシグニ１体を対象とし、あなたの場に他の＜凶蟲＞のシグニがある場合、それをダウンし凍結する。
-- ライフバースト：カードを３枚引き、手札を２枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_HAND) end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) and Duel.SelectYesNo(tp) then Duel.PutOnField(h,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KYOUCHU)) end,tp,LOCATION_SZONE,0,e:GetHandler()):GetCount()>0 then Duel.Down(tc) Duel.Freeze(tc) end end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,3)
    aux.Discard(tp,2)
  end)
  c:RegisterEffect(e3)
end
