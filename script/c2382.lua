-- WX10-003 アイヤイ★ＪＯＫＥＲ
-- 【自】：あなたのシグニ１体がダウン状態で場に出たとき、《緑》《無》を支払ってもよい。そうした場合、そのシグニをアップする。
-- 【出】：あなたのデッキから＜遊具＞のシグニ１枚を探してエナゾーンに置き、デッキをシャッフルする。
-- 【起】《ダウン》：あなたのエナゾーンからシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:IsSigni() and not x:IsUp() end)
  e1:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{G}{C}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}{C}"),REASON_COST)
    local x=eg:GetFirst()
    if x:IsLocation(LOCATION_SZONE) then Duel.Up(x) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end,1):GetFirst()
    if x then Duel.SendToEna(x) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCost(aux.SelfDownCost)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_ENA,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e3)
end
