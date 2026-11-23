-- WD08-015 コードアンチ　ヴォイニ
-- 【起】《ダウン》：あなたのデッキの上からカードを３枚トラッシュに置く。この方法で＜古代兵器＞のシグニが３枚トラッシュに置かれた場合、カードを１枚引く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsUp() end
    Duel.Down(e:GetHandler())
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local n=g:Filter(function(x) return x:IsLocation(LOCATION_TRASH) and x:IsSigni() and x:IsClass(0,RACE_KODAIHEIKI) end,nil):GetCount()
    if n==3 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
