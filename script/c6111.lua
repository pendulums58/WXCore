-- WXEX1-77 アイン＝シュミット
-- 【自】《ターン１回》：対戦相手の場にあるシグニの【出】能力が発動したとき、対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  -- 【出】能力の発動トリガはまだ(対戦相手のシグニが場に出たときで近似)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg)
    return eg:Filter(function(x) return x:GetControler()~=tp and x:IsSigni() end,nil):GetCount()>0
  end)
  e1:SetOperation(function(e,tp) aux.Discard(1-tp,1) end)
  c:RegisterEffect(e1)
end
