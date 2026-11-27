-- WX22-Re02 コードイート　ウナドン
-- 【自】：このシグニがアタックしたとき、このシグニのパワーが10000以上の場合、あなたのデッキから《アクセアイコン》を持つカード１枚を探してエナゾーンに置き、デッキをシャッフルする。
-- 【出】《緑×0》：あなたのエナゾーンにある《アクセアイコン》を持つ＜調理＞のシグニ１枚を対象とし、それをこのシグニの【アクセ】にする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    if e:GetHandler():GetPower()<10000 then return end
    local g=aux.Search(tp,Card.HasAcceIcon,1)
    if g:GetCount()>0 then Duel.SendToEna(g) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end)(x) and x:HasAcceIcon() end,tp,LOCATION_ENA,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local h=e:GetHandler()
    if tc and tc:IsRelateToEffect(e) and h:IsLocation(LOCATION_SZONE) then Duel.Acce(tc,h) end
  end)
  c:RegisterEffect(e2)
end
