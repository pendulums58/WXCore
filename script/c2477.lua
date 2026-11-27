-- WX11-025 コードラビリンス　ピシャトー
-- 【自】：対戦相手のターンの間、このシグニが場を離れたとき、《白》《白》を支払ってもよい。そうした場合、あなたのデッキから＜迷宮＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
-- 【自】：対戦相手のシグニ１体がアタックしたとき、アップ状態のこのシグニをダウンしてもよい。そうした場合、あなたの場にあるすべてのシグニを配置し直す。
-- ライフバースト：あなたのデッキから＜迷宮＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルし、対象の対戦相手のシグニ１体をダウンする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_LEAVE_FIELD)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{W}{W}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}{W}"),REASON_COST)
    local x=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_MEIKYU)) end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) return eg:GetFirst():GetControler()~=tp and eg:GetFirst():IsSigni() end)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_SZONE) and h:IsUp() and Duel.SelectYesNo(tp)) then return end
    Duel.Down(h)
    s.rearrange(tp,tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_MEIKYU)) end,1)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) end
  end)
  c:RegisterEffect(e3)
end
-- 시그니를 하나 골라 다른 존으로(차 있으면 맞바꾼다). 그만둘 때까지
function s.rearrange(tp,p)
  for _=1,6 do
    local c=Duel.SelectCards(tp,Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SIGNI,0,nil),0,1):GetFirst()
    if not c then return end
    local zones={}
    for _,z in ipairs(Duel.GetSigniZones(p)) do if z~=c:GetZone() then zones[#zones+1]=z end end
    local z=Duel.SelectZone(tp,zones)
    if not z then return end
    local o=Duel.GetMatchingGroup(function(x) return x:GetZone()==z end,p,LOCATION_SIGNI,0,nil):GetFirst()
    Duel.SwapSigni(c,o or z)
  end
end
