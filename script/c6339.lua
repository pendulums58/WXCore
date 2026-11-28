-- WXK02-063 メルト・デスサイズ
-- 対戦相手のシグニ１体を対象とし、あなたのデッキの上からカードを５枚トラッシュに置く。この方法でカードが５枚トラッシュに置かれた場合、ターン終了時まで、それのパワーを－15000する。
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
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    local g=Duel.GetDecktopGroup(tp,5)
    local n=g:GetCount()>0 and Duel.SendToTrash(g,REASON_EFFECT) or 0
    if n==5 and tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-15000) end
  end)
  c:RegisterEffect(e1)
end
