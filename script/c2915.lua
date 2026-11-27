-- WX17-026 武装の全知　ギルガメジ
-- 【ライズ】《ライズアイコン》を持つシグニ１体と＜武勇＞のシグニ２体の上に出す
-- 【常】：このシグニのパワーはこの下にあるカード１枚につき＋1000される。
-- 【自】：このシグニがアタックしたとき、この下から好きな枚数のシグニを対象とし、それらをトラッシュに置く。その後、対戦相手のシグニを、レベルの合計がこの方法でトラッシュに置いたシグニのレベルの合計と等しくなるように好きな数対象とし、それらをトラッシュに置く。
-- 【出】：あなたのトラッシュからレベル３以下のシグニ１枚を対象とし、それを場に出す。
-- ライフバースト：あなたのトラッシュから＜武勇＞のシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  -- 【ライズ】 「《ライズアイコン》を持つシグニ１体と＜武勇＞のシグニ２体の上」는 《ライズアイコン》 시그니 1체 위로 근사
  aux.AddRise(c,function(x) return x:IsSigni() and x:HasRiseIcon() end)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e) return 1000*e:GetHandler():GetUnderGroup():GetCount() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local u=h:GetUnderGroup():Filter(Card.IsSigni,nil)
    local g=Duel.SelectCards(tp,u,0,u:GetCount())
    if g:GetCount()==0 then return end
    local sum=0
    for x in g:Iter() do sum=sum+x:GetLevel() end
    Duel.SendToTrash(g,REASON_EFFECT)
    local opp=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    Duel.SetSelectCheck(function(sg) local t=0 for y in sg:Iter() do t=t+y:GetLevel() end return t==sum end)
    local pick=Duel.SelectCards(tp,opp,0,opp:GetCount())
    if pick:GetCount()>0 then Duel.SendToTrash(pick,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BUYU)) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local x=Duel.GetFirstTarget()
    if not (x and x:IsRelateToEffect(e)) then return end
    if Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) else Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e4)
end
