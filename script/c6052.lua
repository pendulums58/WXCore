-- WXEX1-18 ママ♥４　MODE４
-- 【自】《ターン１回》：アタックフェイズの間、あなたの＜英知＞のシグニ１体がバニッシュされたとき、あなたのエナゾーンからそのシグニを場に出す。
-- 【出】：あなたのデッキの上からカードを２枚公開する。その中から＜英知＞のシグニを２枚まで手札に加え、残りをトラッシュに置く。
-- 【起】《コインアイコン》：このターンのアタックフェイズの間、あなたの【英知】能力は有効になる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg)
    return Duel.GetPhase()==PHASE_ATTACK and eg:Filter(function(x) return x:GetOwner()==tp and x:IsSigni() and x:IsClass(0,RACE_EICHI) and x:IsLocation(LOCATION_ENA) end,nil):GetCount()>0
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=eg:Filter(function(x) return x:GetOwner()==tp and x:IsSigni() and x:IsClass(0,RACE_EICHI) and x:IsLocation(LOCATION_ENA) end,nil):GetFirst()
    if tc then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local n=aux.RevealCount(tp,2)
    local g=Duel.GetDecktopGroup(tp,n)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local pick=Duel.SelectCards(tp,g:Filter(aux.ClassFilter(0,RACE_EICHI),nil),0,2)
    if pick:GetCount()>0 then Duel.SendToHand(pick) end
    local rest=g:Filter(function(x) return not pick:IsContains(x) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCoinCost(1)
  e3:SetOperation(function(e,tp)
    aux.eichi_always[tp]=Duel.GetTurnCount()
  end)
  c:RegisterEffect(e3)
end
