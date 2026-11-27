-- WX20-069 参ノ遊　タマイレ
-- 【自】：このシグニが対戦相手のシグニ１体をバニッシュしたとき、手札から＜遊具＞のシグニを３枚捨て、このシグニを場からトラッシュに置いてもよい。そうした場合、あなたのルリグデッキから＜遊具＞のレゾナ１枚を出現条件を無視して場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) return eg:GetFirst():GetOwner()~=tp and Duel.GetBanisher()==e:GetHandler() end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()<3 or not h:IsLocation(LOCATION_SZONE) or not Duel.SelectYesNo(tp) then return end
    Duel.SendToTrash(Duel.SelectCards(tp,g,3,3),REASON_EFFECT+REASON_DISCARD)
    if Duel.SendToTrash(h,REASON_EFFECT)==0 then return end
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_RESONA) and c:IsClass(0,RACE_YUGU) end,tp,LOCATION_LDECK,0,nil),0,1):GetFirst()
    if x then Duel.PutOnField(x,tp,false) end
  end)
  c:RegisterEffect(e1)
end
