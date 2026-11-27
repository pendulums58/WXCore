-- WX08-036 羅石　スピネル
-- 【起】《ダウン》：対戦相手のパワー10000以下のシグニ１体を対象とし、あなたのトラッシュから＜鉱石＞か＜宝石＞のシグニ合計５枚を好きな順番でデッキの一番下に置く。そうした場合、それをバニッシュする。
-- 【起】《赤》このシグニを場からトラッシュに置く：あなたのデッキの上からカードを５枚トラッシュに置く。その後、この効果でトラッシュに置かれた＜鉱石＞と＜宝石＞のシグニを合わせた枚数以下のレベルを持つシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetTarget(aux.BanishPowerTarget(10000))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end,tp,LOCATION_TRASH,0,nil)
    if g:GetCount()<5 then return end
    Duel.SendToDeckBottom(Duel.SelectOrder(tp,Duel.SelectCards(tp,g,5,5)),false)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{R}")
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_SZONE) end
    Duel.SendToTrash(e:GetHandler(),REASON_COST)
  end)
  -- 넘긴 뒤에 고른다
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local n=g:Filter(function(x) return x:IsLocation(LOCATION_TRASH) and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end)(x) end,nil):GetCount()
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=n end,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
