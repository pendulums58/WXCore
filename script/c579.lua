-- WX13-032 幻深水姫　デメニギス
-- 【自】：あなたのライフバーストが発動したとき、対戦相手のシグニ１体を対象とし、それをデッキの一番上に置く。
-- 【自】：このシグニがアタックしたとき、あなたのデッキの一番上を公開する。それが《ライフバースト》を持っていた場合、そのカードをチェックゾーンに置き、そのライフバーストを発動させる。（その後、エナゾーンに置かれる）
-- ライフバースト：あなたのデッキの一番上を公開する。それが《ライフバースト》を持っていた場合、それをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_LIFEBURST)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckPosition(tc,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(x)
    if not x:IsLifeBurst() then return end
    -- 체크 존 대신 에나 존에 두고 발동시킨다(결과적으로 에나 존. 근사)
    if Duel.SendToEna(x)>0 then Duel.FireLifeBurst(x) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(x)
    if x:IsLifeBurst() then Duel.SendToLife(x) end
  end)
  c:RegisterEffect(e3)
end
