-- WX17-036 幻怪　ブラウニー
-- 【常】：あなたのすべての領域にある＜怪異＞のシグニであるカードは【ライフバースト】「対戦相手のシグニ１体を対象とし、それをトラッシュに置く。」を持つ。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 모든 영역의 ＜怪異＞ 시그니 카드가 라이프 버스트를 가진다
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_LIFEBURST)
  g:SetDescription(aux.Ability(id,0))
  g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  g:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT_LIFEBURST)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(1,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end)(x) end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
end
