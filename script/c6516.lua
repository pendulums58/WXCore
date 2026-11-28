-- WXK04-060 羅植　ガウラ
-- 【自】：対戦相手のターンの間、このシグニがバニッシュされたとき、あなたのデッキの一番上を見る。それを【シード】としてあなたのシグニゾーンに出してもよい。
-- 【起】【シード】であるこのカードを公開し、エナゾーンから＜植物＞のシグニ２枚をトラッシュに置く：この【シード】を開花する。
-- 【自】：このシグニが開花したとき、対戦相手のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.ConfirmCards(tp,g)
    if Duel.SelectYesNo(tp) then Duel.SetSeed(x,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  -- 【シード】인 이 카드를 공개한다
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SEED)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end,tp,LOCATION_ENA,0,nil)
    if chk==0 then return g:GetCount()>=2 end
    Duel.RevealCards(e:GetHandler())
    Duel.SendToTrash(Duel.SelectCards(tp,g,2,2),REASON_COST)
  end)
  e2:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SEED) then Duel.Bloom(h) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_BLOOM)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e3)
end
