-- WXK05-064 コードイート　ロールアイス
-- 【自】《ターン２回》：あなたのシグニ１体に【アクセ】が付いたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－3000する。
-- 【出】：対象のあなたの【アクセ】１枚を対象のあなたの＜調理＞のシグニ１体に付けてもよい。（その【アクセ】が付いているシグニを選んでも何も起きない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ACCE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(2)
  e1:SetCondition(function(e,tp,eg) local h=eg:GetFirst():GetAcceHost() return h and h:GetControler()==tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-3000)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    local a=Duel.GetMatchingGroup(nil,tp,LOCATION_ACCE,0,nil)
    if a:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    local x=Duel.SelectCards(tp,a,1,1):GetFirst()
    local h=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(y) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_CHOURI) end)(y) and y~=x:GetAcceHost() and Duel.GetMatchingGroup(function(z) return z:GetAcceHost()==y end,tp,LOCATION_ACCE,0,nil):GetCount()==0 end,tp,LOCATION_SZONE,0,nil),0,1):GetFirst()
    if h then Duel.Acce(x,h) end
  end)
  c:RegisterEffect(e2)
end
