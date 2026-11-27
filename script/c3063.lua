-- WX19-040 ＣＡＰＴＵＲＥ
-- あなたのトラッシュから＜水獣＞のシグニ５枚を対象とし、それらをデッキに加えてシャッフルする。この方法でカードを５枚デッキに加えた場合、カードを２枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end,tp,LOCATION_TRASH,0,5,5,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()<5 then return end
    Duel.SendToDeckShuffle(g,tp)
    Duel.Draw(tp,2)
  end)
  c:RegisterEffect(e1)
end
