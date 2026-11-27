-- WX08-006 黒幻蟲　アラクネ・パイダ
-- 【出現条件】《メインフェイズアイコン》レゾナではない＜凶蟲＞のシグニ２体をあなたの場からトラッシュに置く
-- 【常】：対戦相手は【チャーム】が付いているシグニの【起】能力を使用できない。
-- 【自】：対戦相手のシグニ１体が場に出たとき、対戦相手は自分のデッキの一番上のカードをそのシグニの【チャーム】にする。
-- 【自】：各アタックフェイズ開始時、対戦相手は【チャーム】が付いている自分のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,aux.NonResonaClass(RACE_KYOUCHU))
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_DISABLE_ABILITY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,LOCATION_SZONE)
  e1:SetTarget(function(e,x) return x:GetCharm()~=nil end)
  e1:SetValue(ABILITY_IGNITION)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()~=tp and x:IsSigni() end)
  e2:SetOperation(function(e,tp,eg)
    local x=eg:GetFirst()
    local top=Duel.GetDecktopGroup(1-tp,1):GetFirst()
    if top and x:IsLocation(LOCATION_SZONE) and not x:GetCharm() then Duel.Charm(top,x) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e3:SetRange(LOCATION_SZONE)
  e3:SetOperation(function(e,tp)
    -- 상대가 고른다
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetCharm()~=nil end,1-tp,LOCATION_SZONE,0,nil)
    if g:GetCount()==0 then return end
    local x=Duel.SelectTarget(1-tp,function(x) return x:IsSigni() and x:GetCharm()~=nil end,1-tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if x then Duel.Banish(x) end
  end)
  c:RegisterEffect(e3)
end
