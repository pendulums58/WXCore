-- PR-465 時英の埋設　#タイプス#（ウィクロス大同窓会 バトルラッシュ 参加賞）
-- 【自】：このシグニがアタックしたとき、対戦相手のセンタールリグの下からカードを２枚まで対象とし、あなたのルリグデッキから、あなたのセンタールリグと同じルリグタイプを持つルリグ２枚をルリグトラッシュに置いてもよい。そうした場合、それらをルリグトラッシュに置く。
-- 【出】：あなたのルリグトラッシュからレベル４以下のルリグ１枚を対象とし、それをルリグデッキに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  -- 아래 카드를 대상으로 하는 것은 고르는 것으로 근사
  e1:SetOperation(function(e,tp)
    local oc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not (oc and lc) then return end
    local u=Duel.SelectCards(tp,oc:GetUnderGroup(),0,2)
    if u:GetCount()==0 then return end
    local types=lc:GetLrigTypes()
    local g=Duel.GetMatchingGroup(function(x)
      if not x:IsType(TYPE_LRIG) then return false end
      for _,t in ipairs(types) do if x:IsLrigType(t) then return true end end
      return false
    end,tp,LOCATION_LDECK,0,nil)
    if g:GetCount()<2 or not Duel.SelectYesNo(tp) then return end
    Duel.SendToLrigTrash(Duel.SelectCards(tp,g,2,2),REASON_EFFECT)
    Duel.SendToLrigTrash(u,REASON_EFFECT)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_LRIG) and x:GetLevel()<=4 end,tp,LOCATION_LTRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToLrigDeck(tc) end
  end)
  c:RegisterEffect(e2)
end
