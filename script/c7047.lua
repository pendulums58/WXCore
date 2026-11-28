-- WXK10-073 技英の特異　シンギュラ
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、それを凍結する。
-- （凍結されたシグニは次の自分のアップフェイズにアップしない）
-- 【出】：あなたのトラッシュからレベル３以下の＜英知＞のシグニを１枚まで対象とし、それをデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.Freeze(tc)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_EICHI) end)(x) and x:GetLevel()<=3 end,tp,LOCATION_TRASH,0,0,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local x=Duel.GetFirstTarget()
    if x and x:IsRelateToEffect(e) then Duel.SendToDeckBottom(x,false) end
  end)
  c:RegisterEffect(e2)
end
