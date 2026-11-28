-- WXK03-080 中罠　トケイウサギ
-- 【出】：対戦相手のシグニを２体まで対象とし、あなたのデッキの一番上のカードをトラッシュに置く。それがレベルが偶数のシグニの場合、ターン終了時まで、それらのパワーをそれぞれ－1000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 다른 2체(FAQ 2)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    if not (x:IsSigni() and x:GetLevel()%2==0) then return end
    for tc in Duel.GetTargets():Iter() do if tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-1000) end end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
