-- WXK06-030 幻竜姫　シファル
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニゾーンからカード１枚を対象とし、あなたのデッキの上から＜龍獣＞のシグニが８枚トラッシュに置かれるまでカードをトラッシュに置く。この方法で＜龍獣＞のシグニを８枚トラッシュに置いた場合、それをトラッシュに置き、カードを１枚引く。
-- 【出】ライフクロス１枚をトラッシュに置く：対戦相手は、自分の場からシグニ１体と自分のエナゾーンからカード１枚を対象とし、それらをトラッシュに置く。
-- ライフバースト：あなたのトラッシュから＜龍獣＞のシグニを２枚まで対象とし、それらを手札に加える。
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
    local seen,k=Group.CreateGroup(),0
    local total=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):GetCount()
    for i=1,total do
      local last=nil
      for y in Duel.GetDecktopGroup(tp,i):Iter() do last=y end
      seen:AddCard(last)
      if last:IsSigni() and last:IsClass(0,RACE_RYUJU) then k=k+1 if k>=8 then break end end
    end
    if seen:GetCount()>0 then Duel.SendToTrash(seen,REASON_EFFECT) end
    local tc=Duel.GetFirstTarget()
    if k>=8 and tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local x=Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetFirst()
    if chk==0 then return x~=nil end
    Duel.SendToTrash(x,REASON_COST)
  end)
  e2:SetOperation(function(e,tp,eg)
    local p=1-tp
    local g=Group.CreateGroup()
    local a=Duel.SelectTarget(p,Card.IsSigni,p,LOCATION_SZONE,0,1,1,nil):GetFirst()
    local b=Duel.SelectTarget(p,nil,p,LOCATION_ENA,0,1,1,nil):GetFirst()
    if a then g:AddCard(a) end
    if b then g:AddCard(b) end
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_RYUJU) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e9)
end
