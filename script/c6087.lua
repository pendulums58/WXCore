-- WXEX1-53 大盾槍　ファランクス
-- 【自】《ターン１回》：あなたの＜アーム＞か＜ウェポン＞のシグニ１体が効果によって場に出たとき、そのシグニのパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- 【出】《無》：対戦相手のレベル３以下のシグニ１体を対象とし、あなたのトラッシュから＜アーム＞のシグニ１枚と＜ウェポン＞のシグニ１枚をデッキに加えてシャッフルする。そうした場合、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r)
    return r&REASON_EFFECT~=0 and eg:Filter(function(x) return x:GetControler()==tp and x:IsSigni() and (x:IsClass(0,RACE_ARM) or x:IsClass(0,RACE_WEAPON)) end,nil):GetCount()>0
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local sc=eg:Filter(function(x) return x:GetControler()==tp and x:IsSigni() and (x:IsClass(0,RACE_ARM) or x:IsClass(0,RACE_WEAPON)) end,nil):GetFirst()
    local pw=sc and sc:GetPower() or 0
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=pw end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{C}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local g1=Duel.SelectCards(tp,Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_ARM),tp,LOCATION_TRASH,0,nil),1,1)
    if g1:GetCount()==0 then return end
    local g2=Duel.SelectCards(tp,Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_WEAPON),tp,LOCATION_TRASH,0,g1:GetFirst()),1,1)
    if g2:GetCount()==0 then return end
    g1:AddCard(g2:GetFirst())
    Duel.SendToDeckShuffle(g1,tp)
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
end
