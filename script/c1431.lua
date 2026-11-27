-- WX17-031 大幻蟲　§ヤシガニラ§
-- 【自】：このカードが手札からトラッシュに置かれたとき、対戦相手のシグニ１体を対象とし、《青》《青》《無》を支払ってもよい。そうした場合、それをバニッシュする。
-- 【自】：各アタックフェイズ開始時、このシグニを場から手札に戻してもよい。
-- 【起】《スペルカットインアイコン》手札からこのカードを捨てる：コストの合計が０のスペル１つを対象とし、あなたの場に＜凶蟲＞のシグニがある場合、それの効果を打ち消す。
-- ライフバースト：カードを１枚引く。あなたの場に＜凶蟲＞のシグニがある場合、対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_HAND) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if Duel.CanPayEna(tp,"{U}{U}{C}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}{U}{C}"),REASON_COST)
      if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e2:SetRange(LOCATION_SZONE)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp) then Duel.SendToHand(h) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_HAND)
  e3:SetTiming(TIMING_CUTIN)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_HAND) end
    Duel.SendToTrash(e:GetHandler(),REASON_COST+REASON_DISCARD)
  end)
  e3:SetOperation(function(e,tp)
    local sp=Duel.GetCutinSpell()
    if sp and sp:GetCostTotal()==0 and Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KYOUCHU)) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.NegateSpell() end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KYOUCHU)) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then aux.Discard(1-tp,1) end
  end)
  c:RegisterEffect(e4)
end
