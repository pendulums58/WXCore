-- WX20-053 コードメイズ　リバティ
-- 【自】：各アタックフェイズ開始時、あなたのすべてのシグニを好きなように配置し直す。
-- 【起】《アタックフェイズアイコン》トラッシュにあるこのカードをゲームから除外する：あなたの手札かデッキからカード名に《クイン》を含むシグニ１枚を探して場に出す。その後、この方法でデッキからカードを探していた場合、デッキをシャッフルする。この能力はあなたの場にシグニがない場合にしか使用できない。
local s,id=GetID()
function s.initial_effect(c)
  -- 【自】 「すべてのシグニを好きなように配置し直す」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetRange(LOCATION_TRASH)
  e1:SetTiming(TIMING_ATTACK)
  e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):GetCount()==0 end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_TRASH) end
    Duel.Exclude(e:GetHandler())
  end)
  e1:SetOperation(function(e,tp)
    local f=function(x) return x:IsSigni() and aux.NameHas(x,"クイン") end
    local g=Duel.GetMatchingGroup(f,tp,LOCATION_HAND+LOCATION_MDECK,0,nil)
    local x=Duel.SelectCards(tp,g,0,1):GetFirst()
    local fromdeck=x and x:IsLocation(LOCATION_MDECK)
    if x then Duel.PutOnField(x,tp) end
    if fromdeck then aux.ShuffleDeck(tp) end
  end)
  c:RegisterEffect(e1)
end
