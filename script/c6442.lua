-- WXK03-068 外英の消費　インバウンド
-- 【自】：このシグニがアタックしたとき、あなたのデッキの下からカードを２枚トラッシュに置く。この方法でトラッシュに置かれたシグニのレベルの合計が５の場合、カードを１枚引く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDeckbottomGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local n=0
    for x in g:Iter() do if x:IsSigni() and x:IsLocation(LOCATION_TRASH) then n=n+x:GetLevel() end end
    if n==5 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
