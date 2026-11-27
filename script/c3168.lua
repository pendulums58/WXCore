-- WX20-082 幻蟲　カレハチョウ
-- 【自】：このカードが手札かデッキからトラッシュに置かれたとき、対戦相手のトラッシュから対象のカード１枚を対象の対戦相手のシグニ１体の【チャーム】にしてもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e) local h=e:GetHandler() return h:IsPreviousLocation(LOCATION_HAND) or h:IsPreviousLocation(LOCATION_MDECK) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,nil,tp,0,LOCATION_TRASH,0,1,nil):GetFirst()
    s.b=s.a and Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:GetCharm() end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    if s.a and s.b and s.a:IsRelateToEffect(e) and s.b:IsRelateToEffect(e) then Duel.Charm(s.a,s.b) end
  end)
  c:RegisterEffect(e1)
end
