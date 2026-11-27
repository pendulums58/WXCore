-- WX06-001 永らえし者　タウィル＝フィーラ
-- 【常】：あなたの＜天使＞のシグニのパワーを＋1000する。
-- 【起】《ターン１回》《白×0》：対戦相手のシグニ１体を対象とし、あなたのトラッシュから＜天使＞のシグニ７枚をデッキの一番下に置く。そうした場合、それをバニッシュし、デッキをシャッフルする。
-- 【起】《ターン１回》《白×0》：対戦相手のシグニ１体を対象とし、あなたのトラッシュから名前の異なる＜天使＞のシグニ７枚をデッキの一番下に置く。そうした場合、それをトラッシュに置き、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end)(x) end)
  e1:SetValue(1000)
  c:RegisterEffect(e1)
  -- 각각 턴 1회(FAQ 3). 상대 시그니가 있으면 대상으로 해야 한다(FAQ 5)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_TRASH,0,nil)
    -- 7장이 없으면 하나도 두지 않는다(FAQ 6)
    if g:GetCount()<7 then return end
    
    local pick=Duel.SelectCards(tp,g,7,7)
    if pick:GetCount()<7 then return end
    Duel.SendToDeckBottom(Duel.SelectOrder(tp,pick),false)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_TRASH,0,nil)
    -- 7장이 없으면 하나도 두지 않는다(FAQ 6)
    if s.names(g)<7 then return end
    Duel.SetSelectCheck(function(sg)
      local seen={}
      for x in sg:Iter() do
        if seen[x:GetCode()] then return false end
        seen[x:GetCode()]=true
      end
      return true
    end)
    local pick=Duel.SelectCards(tp,g,7,7)
    if pick:GetCount()<7 then return end
    Duel.SendToDeckBottom(Duel.SelectOrder(tp,pick),false)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
function s.names(g)
  local seen,n={},0
  for x in g:Iter() do
    if not seen[x:GetCode()] then
      seen[x:GetCode()]=true
      n=n+1
    end
  end
  return n
end
