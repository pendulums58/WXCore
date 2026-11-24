-- WDK06-C08 タクティカル・パニッシュ
-- 対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－3000する。あなたのトラッシュにカードが１５枚以上ある場合、代わりにターン終了時まで、それのパワーを－8000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  -- [まで] 처리할 때의 트래시 장수로 정한다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil):GetCount()>=15 and -8000 or -3000) end
  end)
  c:RegisterEffect(e1)
end
