-- WDK08-L04 英血の器　優羽莉　Ｌｖ１
-- 【出】手札を１枚捨てる：《コインアイコン》を得る。
-- 【起】《ターン１回》《赤×0》：あなたの＜紅蓮＞のシグニ１体を対象とし、それを血晶武装［手札］する。
local s,id=GetID()
s.guren=aux.ClassFilter(0,RACE_GUREN)  -- ＜紅蓮＞のシグニ
function s.initial_effect(c)
  -- 코스트가 있는 【出】은 쓰지 않아도 된다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()>=1 end
    Duel.SendToTrash(Duel.SelectDiscard(tp,1,1),REASON_COST+REASON_DISCARD)
  end)
  e1:SetOperation(function(e,tp) Duel.AddCoin(tp,1) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.guren,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.BloodArm(tp,tc,LOCATION_HAND) end
  end)
  c:RegisterEffect(e2)
end
