-- WX19-054 弩砲　テイザー
-- 【自】《ターン１回》：あなたのセンタールリグがアタックしたとき、数字１つを宣言する。このターン、対戦相手は宣言された数字と同じレベルのシグニで【ガード】ができない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:IsType(TYPE_LRIG) end)
  e1:SetOperation(function(e,tp)
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
  c:RegisterEffect(e1)
end
