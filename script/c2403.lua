-- WX10-028 羅星姫　タンサーフォー
-- 【自】：あなたのレゾナ１体が場に出たとき、このシグニをアップする。
-- 【自】：このシグニが対戦相手のライフクロス１枚をクラッシュしたとき、レゾナ１体を対象とし、《白》を支払ってもよい。そうした場合、それをアップする。
-- 【起】《ダウン》レゾナではない他のシグニ１体を場からトラッシュに置く：この方法でトラッシュに置いたシグニと同じレベルの対戦相手のシグニ１体を対象とし、それを手札に戻す。
-- ライフバースト：あなたのルリグデッキからレゾナ１枚を出現条件を無視して場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:IsType(TYPE_RESONA) end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_CRUSHED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetCrusher()==e:GetHandler() end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_RESONA) end,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{W}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}"),REASON_COST)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Up(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and not x:IsType(TYPE_RESONA) end,tp,LOCATION_SZONE,0,h)
    if chk==0 then return h:IsUp() and g:GetCount()>0 end
    Duel.Down(h,REASON_COST)
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    e:SetLabel(x:GetLevel())
    Duel.SendToTrash(x,REASON_COST)
  end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==e:GetLabel() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_RESONA) end,tp,LOCATION_LDECK,0,nil),0,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e4)
end
