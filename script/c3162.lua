-- WX20-076 情愛の反旗　†アークフラウド†
-- 【自】：このシグニがバニッシュされたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－7000する。あなたの場にカード名に《アークゲイン》を含むシグニがある場合、代わりに対戦相手のシグニを２体まで対象とし、ターン終了時まで、それらのパワーをそれぞれ－7000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetOperation(function(e,tp)
    local n=(Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"アークゲイン") end,tp,LOCATION_SZONE,0,nil):GetCount()>0) and 2 or 1
    local g=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,n==2 and 0 or 1,n,nil)
    for tc in g:Iter() do aux.AddPower(e,tc,-7000) end  -- [まで]
  end)
  c:RegisterEffect(e1)
end
