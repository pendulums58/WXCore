-- WXK09-029 波奏の蒼天　トリトン
-- 【自】《ターン１回》：あなたがスペルを使用したとき、《青》を支払ってもよい。そうした場合、対戦相手は手札を１枚捨てる。
-- 【起】《ターン１回》《無》トラッシュにあるそれぞれ名前の異なるスペル３枚をゲームから除外する：対戦相手のシグニ１体を対象とし、それをデッキの一番上に置く。
-- ライフバースト：あなたのトラッシュから無色ではないシグニ１枚を対象とし、それを手札に加える。その後、あなたのトラッシュからそのシグニと共通する色を持つスペル１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_USE_CARD)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp and eg:GetFirst():IsType(TYPE_SPELL) end)
  e1:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
    aux.Discard(1-tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetEnaCost("{C}")
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_TRASH,0,nil)
    if chk==0 then local n,seen=0,{} for x in g:Iter() do if not seen[x:GetCode()] then seen[x:GetCode()]=true n=n+1 end end return n>=3 end
    local pick,seen=Group.CreateGroup(),{}
    for i=1,3 do
      local x=Duel.SelectCards(tp,g:Filter(function(y) return not seen[y:GetCode()] end,nil),1,1):GetFirst()
      seen[x:GetCode()]=true
      pick:AddCard(x)
    end
    Duel.Exclude(pick)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToDeckPosition(tc,1)
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    local a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetColor()~=0 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if not a then return end
    Duel.SendToHand(a)
    local b=Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) and (x:GetColor()&a:GetColor())~=0 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if b then Duel.SendToHand(b) end
  end)
  c:RegisterEffect(e9)
end
