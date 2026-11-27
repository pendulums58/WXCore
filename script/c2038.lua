-- WX04-061 コードメイズ　タワブ
-- 【常】：あなたの場に他の＜迷宮＞のシグニがあるかぎり、このシグニの基本パワーは3000になる。
-- 【出】：あなたのシグニ１体を対象とし、それとこのシグニの場所を入れ替えてもよい。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePowerWhileClass(c,RACE_MEIKYU,3000)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SIGNI,0,0,1,e:GetHandler())
  end)
  e1:SetOperation(function(e,tp)
    local tc,h=Duel.GetFirstTarget(),e:GetHandler()
    if tc and tc:IsRelateToEffect(e) and h:IsLocation(LOCATION_SIGNI) and Duel.SelectYesNo(tp) then Duel.SwapSigni(h,tc) end
  end)
  c:RegisterEffect(e1)
end
