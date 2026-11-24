-- WDK07-E07 パワー・デコレート
-- あなたの＜調理＞のシグニを２体まで対象とし、あなたのデッキから＜調理＞のシグニを２枚まで探してそれらの【アクセ】にし、デッキをシャッフルする。
-- （【アクセ】はシグニ１体に１枚までしか付けられない）
local s,id=GetID()
s.chouri=aux.ClassFilter(0,RACE_CHOURI)  -- ＜調理＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.chouri,tp,LOCATION_SZONE,0,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    local hosts=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) and not x:IsAcce() end,nil)
    for ac in aux.Search(tp,s.chouri,2):Iter() do
      local h=hosts:GetFirst()
      if hosts:GetCount()>1 then h=Duel.SelectCards(tp,hosts,1,1):GetFirst() end
      if h and Duel.Acce(ac,h) then hosts=hosts:Filter(function(x) return x~=h end,nil) end
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
