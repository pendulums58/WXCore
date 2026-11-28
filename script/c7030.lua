-- WXK10-056 兄妹の原童話　アリョーヌ
-- 【自】《ターン１回》：あなたの他のシグニ１体がコストとして場からトラッシュに置かれたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをトラッシュに置かれたそのシグニのレベル１につき－1000する。
-- 【出】手札からシグニを１枚捨てる：あなたのトラッシュからこの方法で捨てたシグニと共通するクラスを持つレベル２以下のシグニ１枚を対象とし、それを手札に加える。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) if (r&REASON_COST)==0 then return false end for x in eg:Iter() do if x~=e:GetHandler() and x:IsPreviousLocation(LOCATION_SZONE) and x:GetOwner()==tp then return true end end return false end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local n=0
      for x in eg:Iter() do if x:IsPreviousLocation(LOCATION_SZONE) then n=n+x:GetLevel() end end
      aux.AddPower(e,tc,-1000*n)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_HAND,0,nil)
    if chk==0 then return g:GetCount()>0 end
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    s.dc=x
    Duel.SendToTrash(x,REASON_COST+REASON_DISCARD)
  end)
  e2:SetOperation(function(e,tp,eg)
    local d0=s.dc
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=2 and x~=d0 and (function(a,b) local g=Group.CreateGroup() g:AddCard(a) g:AddCard(b) return aux.ShareClass(g) end)(x,d0) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
