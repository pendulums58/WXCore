-- WX21-025 神罠　フーディナ
-- 【自】：対戦相手のシグニ１体が【トラップ】のあるシグニゾーンに出たとき、そのシグニとその【トラップ】をトラッシュに置く。
-- 【出】：対戦相手のシグニ１体を対象とし、それを【トラップ】としてそのシグニゾーンに設置する。
-- 【トラップアイコン】対戦相手のシグニ１体を対象とし、手札から＜トリック＞のシグニを２枚捨てるか《青》《青》を支払ってもよい。そうした場合、それを【トラップ】としてそのシグニゾーンに設置する。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それを【トラップ】としてそのシグニゾーンに設置する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() if x:GetControler()==tp or not x:IsSigni() then return false end local z=x:GetZone() return Duel.GetMatchingGroup(function(t) return t:GetZone()==z end,tp,0,LOCATION_TRAP,nil):GetCount()>0 end)
  e1:SetOperation(function(e,tp,eg)
    local x=eg:GetFirst()
    local z=x:GetZone()
    local g=Duel.GetMatchingGroup(function(t) return t:GetZone()==z end,tp,0,LOCATION_TRAP,nil)
    if x:IsLocation(LOCATION_SZONE) then g:AddCard(x) end
    Duel.SendToTrash(g,REASON_EFFECT)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then -- 「そのシグニゾーンに【トラップ】として」: 상대 시그니를 상대 존의 【トラップ】으로 둔다(존은 고르는 것으로 근사)
        Duel.SetTrap(tc,1-tp) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_TRAP)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TRICK)) end,tp,LOCATION_HAND,0,nil)
    -- 예 = 패 2장 버리기, 아니오 = 《青》《青》
    local ok=false
    if g:GetCount()>=2 and Duel.SelectYesNo(tp) then Duel.SendToTrash(Duel.SelectCards(tp,g,2,2),REASON_EFFECT+REASON_DISCARD) ok=true
    elseif Duel.CanPayEna(tp,"{U}{U}") and Duel.SelectYesNo(tp) then Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}{U}"),REASON_COST) ok=true end
    if ok then
    -- 「そのシグニゾーンに【トラップ】として」: 상대 시그니를 상대 존의 【トラップ】으로 둔다(존은 고르는 것으로 근사)
    Duel.SetTrap(tc,1-tp)
    end
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
    if tc and tc:IsRelateToEffect(e) then -- 「そのシグニゾーンに【トラップ】として」: 상대 시그니를 상대 존의 【トラップ】으로 둔다(존은 고르는 것으로 근사)
        Duel.SetTrap(tc,1-tp) end
  end)
  c:RegisterEffect(e4)
end
