-- WDK06-C14 魏軍の赤弓　カコウエン
-- 【出】手札を１枚捨てる：あなたのトラッシュからレベル３以下の＜武勇＞のシグニ１枚を対象とし、あなたのターンの場合、それを場に出す。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
s.buyu=aux.ClassFilter(0,RACE_BUYU)  -- ＜武勇＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1))
  -- 코스트로 버린 시그니도 고를 수 있다(FAQ 3)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return s.buyu(x) and x:IsLevelBetween(0,3) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if Duel.GetTurnPlayer()==tp and tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
