-- WX10-009 縛魔炎　花代・参
-- 【常】：あなたのグロウフェイズをスキップする。
-- 【自】：あなたがスペルを使用したとき、このルリグをアップする。
-- 【起】《ダウン》：数字１つを宣言する。このターン、対戦相手は宣言された数字と同じレベルのシグニで【ガード】ができない。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_SKIP_GROW)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(1,0)
  c:RegisterEffect(e1)
  -- 打ち消されても(FAQ 1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_USE_CARD)
  e2:SetRange(LOCATION_LRIG)
  e2:SetCondition(function(e,tp,eg,ep) return ep==tp and eg:GetFirst():IsType(TYPE_SPELL) end)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_LRIG) then Duel.Up(h) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCost(aux.SelfDownCost)
  e3:SetOperation(function(e,tp)
    local n=Duel.AnnounceNumber(tp,0,5)
    -- [の間] 「このターン」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_GUARD)
    e1:SetTargetRange(0,1)
    e1:SetValue(n)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e3)
end
