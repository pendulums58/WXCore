-- WXK10-033 罠英の錬金　カリオストロ
-- 【自】：このシグニがアタックしたとき、このシグニを場からトラッシュに置いてもよい。そうした場合、あなたの手札からレベル３のシグニ１枚を場に出す。
-- 【出】手札からシグニを１枚捨てる：あなたのデッキからこの方法で捨てたシグニよりレベルが２つ高い、それと共通するクラスを持つシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) or Duel.SendToTrash(h,REASON_EFFECT)==0 then return end
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetLevel()==3 end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()>0 then Duel.PutOnField(Duel.SelectCards(tp,g,1,1):GetFirst(),tp) end
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
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:GetLevel()==d0:GetLevel()+2 and (function(a,b) local g=Group.CreateGroup() g:AddCard(a) g:AddCard(b) return aux.ShareClass(g) end)(x,d0) end,1)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
