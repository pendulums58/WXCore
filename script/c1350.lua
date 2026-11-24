-- WD22-026-U 堕落の消滅　アリトン
-- 【自】：このカードが手札かデッキからトラッシュに置かれたとき、あなたのシグニ１体を対象とし、このカードをそれの【チャーム】にしてもよい。
-- （【チャーム】は裏向きでシグニに付き、１体に１枚までしか付けられない）
local s,id=GetID()
function s.initial_effect(c)
  -- 한정 조건과 관계없다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_MDECK) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc,h=Duel.GetFirstTarget(),e:GetHandler()
    if tc and tc:IsRelateToEffect(e) and h:IsLocation(LOCATION_TRASH) and not tc:GetCharm() and Duel.SelectYesNo(tp) then Duel.Charm(h,tc) end
  end)
  c:RegisterEffect(e1)
end
