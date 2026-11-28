-- SPK01-08 衆英の出資　クラファン（パーティーパックVol.3）
-- 【出】：あなたのデッキの上からカードを４枚見る。その中から３枚を好きな順番でデッキの一番下に置き、残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  -- 3장 이하면 전부 덱으로(FAQ 1·2)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local n=math.min(3,g:GetCount())
    local keep=Duel.SelectCards(tp,g,n,n)
    local rest=g:Filter(function(x) return not keep:IsContains(x) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
    Duel.SendToDeckBottom(Duel.SelectOrder(tp,keep),false)
  end)
  c:RegisterEffect(e1)
end
