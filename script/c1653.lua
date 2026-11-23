-- WDK08-L11 紅蓮の使い魔　ツクヨミ
-- 【常】：このシグニは血晶武装状態であるかぎり、「【自】：このシグニがアタックしたとき、対戦相手のシグニを２体まで対象とし、《赤》《赤》を支払ってもよい。そうした場合、それらをバニッシュする。」を得る。
-- 【出】《赤》《赤》：あなたのトラッシュから《紅蓮の使い魔　ツクヨミ》以外の＜紅蓮＞のシグニ１枚を対象とし、それを手札に加える。
-- ライフバースト：対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
s.guren=aux.ClassFilter(0,RACE_GUREN)  -- ＜紅蓮＞のシグニ
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  g:SetOperation(s.atkop)
  -- [の間] 【常】 血晶武装状態인 동안 위 【自】를 얻는다. 얻은 【自】로 정면을 바니시해도 그 뒤 데미지는 준다(FAQ 3)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SIGNI,0)
  e1:SetTarget(function(e,x) return x==e:GetHandler() and x:IsBloodArmed() end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{R}{R}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return s.guren(x) and not x:IsSameName(e:GetHandler()) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=12000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
end
-- 「《赤》《赤》を支払ってもよい。そうした場合」: 처리할 때 낼지 고른다
function s.atkop(e,tp)
  if not (Duel.CanPayEna(tp,"{R}{R}") and Duel.SelectYesNo(tp)) then return end
  Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}{R}"),REASON_COST)
  for tc in Duel.GetTargets():Iter() do
    if tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end
end
