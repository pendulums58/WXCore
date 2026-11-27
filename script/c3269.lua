-- WX22-049 デス・ブロッサム
-- あなたのシグニ１体を対象とし、それをバニッシュする。そうした場合、各プレイヤーは自分のデッキの上からカードを３枚トラッシュに置く。その後、あなたのトラッシュから無色ではないレベル１のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) or Duel.Banish(tc)==0 then return end
    for p=0,1 do local g=Duel.GetDecktopGroup(p,3) if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end end
    local x=Duel.SelectTarget(tp,function(c) return c:IsSigni() and c:GetColor()~=0 and c:GetLevel()==1 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if x then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e1)
end
