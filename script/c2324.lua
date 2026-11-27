-- WX08-078 幻蟲　ミンミン
-- 【自】：このシグニが場を離れたとき、対戦相手のトラッシュから対象のカード１枚を対象の対戦相手のシグニ１体の【チャーム】にしてもよい。
-- （【チャーム】は裏向きでシグニに付き、１体に１枚までしか付けられない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_LEAVE_FIELD)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.c=Duel.SelectTarget(tp,nil,tp,0,LOCATION_TRASH,0,1,nil):GetFirst()
    s.h=s.c and Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:GetCharm() end,tp,0,LOCATION_SZONE,0,1,nil):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    if not (s.c and s.h and s.c:IsRelateToEffect(e) and s.h:IsRelateToEffect(e)) then return end
    if not s.h:GetCharm() and Duel.SelectYesNo(tp) then Duel.Charm(s.c,s.h) end
  end)
  c:RegisterEffect(e1)
end
