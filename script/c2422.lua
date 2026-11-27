-- WX10-052 サーバント　Ｙ
-- 【常】：【マルチエナ】
-- 【出】：あなたのトラッシュから《ガードアイコン》を持つシグニ１枚を対象とし、それを手札に加える。
-- 【起】手札からそれぞれ名前の異なる＜精元＞のシグニを４枚捨てる：無色ではないすべてのシグニをトラッシュに置く。
-- ライフバースト：あなたのトラッシュから《ガードアイコン》を持つシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_MULTI_ENA)
  e1:SetRange(LOCATION_ENA)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasGuardIcon() end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(SYS_SEIGEN,0) end,tp,LOCATION_HAND,0,nil)
    local names={}
    local n=0
    for x in g:Iter() do if not names[x:GetCode()] then names[x:GetCode()]=true n=n+1 end end
    if chk==0 then return n>=4 end
    Duel.SetSelectCheck(function(sg)
      local seen={}
      for x in sg:Iter() do
        if seen[x:GetCode()] then return false end
        seen[x:GetCode()]=true
      end
      return true
    end)
    Duel.SendToTrash(Duel.SelectCards(tp,g,4,4),REASON_COST+REASON_DISCARD)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetColor()~=0 end,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasGuardIcon() end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e4)
end
