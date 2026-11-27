-- WX20-063 羅原　Ｘｅ
-- 【自】：対戦相手がスペルを使用したとき、対戦相手は手札を１枚捨てる。
-- 【出】他の＜原子＞のシグニ１体を場からトラッシュに置く：あなたのデッキからコストの合計が０のスペル１枚を探して公開し手札に加え、デッキをシャッフルする。
-- 【起】《アタックフェイズアイコン》《青×0》：あなたのカード名に《Ne》を含むシグニ１体とこのシグニをバニッシュする。そうした場合、対戦相手のすべてのシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_USE_CARD)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep~=tp and eg:GetFirst():IsType(TYPE_SPELL) end)
  e1:SetOperation(function(e,tp)
    aux.Discard(1-tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,tp,LOCATION_SZONE,0,e:GetHandler())
    if chk==0 then return g:GetCount()>0 end
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsType(TYPE_SPELL) and x:GetCostTotal()==0 end,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and aux.NameHas(x,"Ｎｅ") end,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()==0 then return end
    local a=Duel.SelectCards(tp,g,1,1)
    a:AddCard(e:GetHandler())
    if Duel.Banish(a)<2 then return end
    local o=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if o:GetCount()>0 then Duel.Banish(o) end
  end)
  c:RegisterEffect(e3)
end
