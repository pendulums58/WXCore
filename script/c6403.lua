-- WXK03-029 サーバント　F
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、あなたのセンタールリグが＜夢限＞の場合、手札から＜精元＞のシグニを２枚捨ててもよい。そうした場合、それをトラッシュに置く。
-- 【出】《無》：あなたのデッキから《ガードアイコン》を持つシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：あなたのトラッシュから＜精元＞のシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not (tc and tc:IsRelateToEffect(e) and lc and lc:IsLrigType(LRIG_MUGEN)) then return end
    local h=Duel.GetMatchingGroup(aux.ClassFilter(SYS_SEIGEN,0),tp,LOCATION_HAND,0,nil)
    if h:GetCount()>=2 and Duel.SelectYesNo(tp) and Duel.SendToTrash(Duel.SelectCards(tp,h,2,2),REASON_EFFECT+REASON_DISCARD)==2 then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{C}")
  e2:SetOperation(function(e,tp,eg)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:HasGuardIcon() end,1)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(SYS_SEIGEN,0),tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e9)
end
