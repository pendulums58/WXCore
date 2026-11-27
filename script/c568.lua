-- WX06-017 極拳　ニャローブ
-- 【常】：このシグニのパワーはあなたの場にある他の＜アーム＞のシグニ１体につき＋1000される。
-- 【自】：あなたの＜アーム＞のシグニ１体がバニッシュされたとき、シグニ１体を対象とし、それをアップするかダウンする。
-- 【出】《白》：あなたのデッキからカード名に《拳》を含むシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e) return 1000*Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,e:GetHandler()):GetCount() end)
  c:RegisterEffect(e1)
  -- 자신이 바니시돼도(FAQ 2). 다시 업하면 또 어택할 수 있다(FAQ 1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetRange(LOCATION_SZONE+LOCATION_ENA)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() local h=e:GetHandler() return x:GetOwner()==tp and x:IsPreviousLocation(LOCATION_SZONE) and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end)(x) and (h:IsLocation(LOCATION_SZONE) or x==h) end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if tc:IsUp() then Duel.Down(tc) else Duel.Up(tc) end end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{W}")
  e3:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and aux.NameHas(x,"拳") end,1)
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e4)
end
