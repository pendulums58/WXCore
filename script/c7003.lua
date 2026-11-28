-- WXK10-029 罠書竜　ティアマー
-- 【自】：このシグニがアタックしたとき、表記されているパワーと異なるパワーの対戦相手のシグニ１体を対象とし、手札から黒のシグニを１枚捨ててもよい。そうした場合、それをバニッシュする。
-- 【出】《黒》手札から黒のシグニを１枚捨てる：あなたのデッキの上からカードを３枚公開する。その中からこの能力のコストで捨てたシグニと共通するクラスを持つシグニを２枚まで手札に加え、残りをトラッシュに置く。
-- ライフバースト：手札を１枚捨てる。対象の対戦相手のシグニ１体をバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()~=x:GetBasePower() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local h=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_HAND,0,nil)
      if h:GetCount()>0 and Duel.SelectYesNo(tp) and Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD)>0 then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{B}")
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return g:GetCount()>0 end
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    s.dc=x
    Duel.SendToTrash(x,REASON_COST+REASON_DISCARD)
  end)
  e2:SetOperation(function(e,tp,eg)
    local d0=s.dc
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local s=g:Filter(function(x) return x:IsSigni() and (function(a,b) local g=Group.CreateGroup() g:AddCard(a) g:AddCard(b) return aux.ShareClass(g) end)(x,d0) end,nil)
    if s:GetCount()>0 then Duel.SendToHand(Duel.SelectCards(tp,s,0,2)) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    aux.Discard(tp,1)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e9)
end
