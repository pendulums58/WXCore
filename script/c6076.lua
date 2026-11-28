-- WXEX1-42 羅植姫　ドラゴンツリー
-- 【自】《ターン１回》：あなたの他の＜植物＞のシグニ１体がダウン状態になったとき、そのシグニのパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- 【出】：あなたのエナゾーンから＜植物＞のシグニを１枚まで対象とし、それを手札に加える。
-- ライフバースト：あなたのエナゾーンから＜植物＞のシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_DOWN)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg)
    local h=e:GetHandler()
    return eg:Filter(function(x) return x~=h and x:GetControler()==tp and x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end,nil):GetCount()>0
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local h=e:GetHandler()
    local sc=eg:Filter(function(x) return x~=h and x:GetControler()==tp and x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end,nil):GetFirst()
    local pw=sc and sc:GetPower() or 0
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=pw end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_SHOKUBUTSU),tp,LOCATION_ENA,0,0,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_SHOKUBUTSU),tp,LOCATION_ENA,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.SendToHand(tc) else Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e9)
end
