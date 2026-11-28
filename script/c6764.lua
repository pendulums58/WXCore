-- WXK07-066 羅原　Ka
-- 【自】《ターン１回》：あなたの＜原子＞のシグニ１体がコストか効果によって場からトラッシュに置かれたとき、カードを１枚引き、手札を１枚捨てる。（このシグニが場からトラッシュに置かれたときも発動する）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 이 시그니 자신이 트래시에 놓였을 때도(카드 주석)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetRange(LOCATION_SZONE+LOCATION_TRASH)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) if (r&(REASON_EFFECT|REASON_COST))==0 or (r&REASON_BANISH)~=0 then return false end for x in eg:Iter() do if x:IsPreviousLocation(LOCATION_SZONE) and x:GetOwner()==tp and (function(x) return x:IsSigni() and x:IsClass(0,RACE_GENSHI) end)(x) and (x==e:GetHandler() or e:GetHandler():IsLocation(LOCATION_SZONE)) then return true end end return false end)
  e1:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e1)
end
