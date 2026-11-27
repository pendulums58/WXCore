-- WX16-028 超罠　チュモーイ
-- 【自】：このシグニがアタックしたとき、正面のシグニ１体を対象とし、あなたのデッキの一番上のカードをトラッシュに置いてもよい。この方法でトラッシュに置かれたカードが《トラップアイコン》を持っていた場合、それを手札に戻す。
-- 【出】：あなたの【トラップ】１つを対象とし、それを手札に加える。そうした場合、それがあったシグニゾーンに手札からカード１枚を【トラップ】として設置する。
-- 【自】：あなたの《トラップアイコン》が発動したとき、《青》を支払ってもよい。そうした場合、このカードをあなたのトラッシュから手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not (x and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(x,REASON_EFFECT)
    if x:HasTrapIcon() and x:IsLocation(LOCATION_TRASH) then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_TRAP,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) or Duel.SendToHand(tc)==0 then return end
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if h:GetCount()>0 then Duel.SetTrap(Duel.SelectCards(tp,h,1,1):GetFirst(),tp) end  -- 「それがあったシグニゾーン」은 고르는 것으로 근사
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_TRAP)
  e3:SetRange(LOCATION_TRASH)
  e3:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e3:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) and Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
      Duel.SendToHand(h)
    end
  end)
  c:RegisterEffect(e3)
end
