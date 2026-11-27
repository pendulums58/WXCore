-- WX08-066 ＢＥＡＵＴＩＦＵＬ
-- 対戦相手のシグニを２体まで対象とし、それらをダウンし凍結する。あなたの場にクロス状態のシグニがある場合、カードを１枚引く。
-- （凍結されたシグニは次の自分のアップフェイズにアップしない）
-- ライフバースト：あなたのデッキから《クロスアイコン》を持つシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    Duel.Down(g)
    Duel.Freeze(g)
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsCross() end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:HasCrossIcon() end,1)
  end)
  c:RegisterEffect(e2)
end
