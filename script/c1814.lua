-- WDK17-009 愛憎の果てに　ハイティ・鍵
-- 【自】《ターン１回》：対戦相手のアタックフェイズの間、あなたのライフクロスがクラッシュされたとき、以下の３つから１つを選ぶ。
-- ①カードを１枚引く。②対戦相手のダウン状態のシグニ１体を対象とし、それをバニッシュする。
-- ③あなたのセンタールリグが＜アルフォウ＞であなたのライフクロスが１枚以下の場合、対戦相手のライフクロス１枚をクラッシュする。
-- 【起】このキーを場からルリグトラッシュに置く：対戦相手は自分の場からシグニ１体と自分のエナゾーンからカード１枚を対象とする。あなたのライフクロスが２枚以下の場合、対戦相手は、手札を１枚捨てそれらをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_KEY)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp and Duel.GetTurnPlayer()~=tp and Duel.GetPhase()==PHASE_ATTACK end)
  -- 조건은 처리할 때 본다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
    if m==0 then
      Duel.Draw(tp,1)
    elseif m==1 then
      local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:IsUp() end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    else
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      if lc and lc:IsLrigType(LRIG_ALFOU) and Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=1 then Duel.Crush(1-tp,1) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(1-tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SelectTarget(1-tp,nil,tp,0,LOCATION_ENA,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()>2 then return end
    aux.Discard(1-tp,1)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
