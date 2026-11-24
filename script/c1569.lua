-- WDK06-C17 魏軍の両斧　チョウリョウ
-- 【出】：あなたの他の＜武勇＞のシグニ１体を対象とし、ターン終了時まで、それのパワーをあなたのトラッシュにある＜武勇＞のシグニ２枚につき＋1000する。この効果は２０枚までしか適用されない。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
s.buyu=aux.ClassFilter(0,RACE_BUYU)  -- ＜武勇＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.buyu,tp,LOCATION_SZONE,0,1,1,e:GetHandler())
  end)
  -- [まで] 2장마다 ＋1000, 20장까지(FAQ 1)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local n=math.min(20,Duel.GetMatchingGroup(s.buyu,tp,LOCATION_TRASH,0,nil):GetCount())//2
    if n>0 and tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,1000*n) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
