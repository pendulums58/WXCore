-- WXK10-059 羅植　オドリコソウ
-- 【自】：このシグニがアタックしたとき、あなたの【シード】１枚を対象とし、それを開花してもよい。
-- 【自】《ターン１回》：あなたの他のシグニ１体が開花したとき、あなたのデッキの一番上を見る。それを【シード】としてあなたのシグニゾーンに出すか、エナゾーンに置く。
-- 【自】：このシグニが開花したとき、対戦相手のレベル３以下のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_SEED,0,nil)
    if g:GetCount()>0 and Duel.SelectYesNo(tp) then Duel.Bloom(Duel.SelectCards(tp,g,1,1):GetFirst()) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BLOOM)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x~=e:GetHandler() and x:GetControler()==tp end)
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.ConfirmCards(tp,g)
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.SetSeed(x,tp) else Duel.SendToEna(x) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_BLOOM)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e3)
end
