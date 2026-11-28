-- WXK09-040 穏領の蒼天　ネーレウス
-- 【常】：このシグニは中央のシグニゾーンにあるかぎり、「【自】《ターン１回》：このシグニがアタックしたとき、カードを１枚引く。その後、このターンにあなたがドローフェイズ以外でカードを３枚以上引いていた場合、あなたのシグニ１体を対象とし、それをアップする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Stringid(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    if Duel.GetDrawCount(tp)>=3 then
      local x=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
      if x then Duel.Up(x) end
    end
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsInZone("signi_center") end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
end
