-- WD07-001 フル/メイデン　イオナ
-- 【常】：対戦相手のシグニは可能ならばアタックしなければならない。
-- 【常】：あなたの場に白と黒のシグニがあるかぎり、対戦相手のシグニのパワーを－2000する。
-- 【起】《黒》手札から白のシグニ１枚と黒のシグニ１枚を捨てる：対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_MUST_ATTACK)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(0,LOCATION_SIGNI)
  c:RegisterEffect(e1)
  -- [の間] 【常】 나중에 나온 시그니도, 【出】보다 먼저 적용(FAQ 1·2)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_LRIG)
  e2:SetTargetRange(0,LOCATION_SIGNI)
  e2:SetCondition(s.wb)
  e2:SetValue(-2000)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetEnaCost("{B}")
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local hand=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_HAND,0,nil)
    if chk==0 then return s.pair(hand) end
    Duel.SetSelectCheck(function(sg) return sg:GetCount()==2 and s.pair(sg) end)
    Duel.SendToTrash(Duel.SelectDiscard(tp,2,2,Card.IsSigni),REASON_COST+REASON_DISCARD)
  end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end
function s.wb(e)
  return Duel.GetMatchingGroup(s.white,e:GetHandlerPlayer(),LOCATION_SIGNI,0,nil):GetCount()>0
     and Duel.GetMatchingGroup(s.black,e:GetHandlerPlayer(),LOCATION_SIGNI,0,nil):GetCount()>0
end
function s.white(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end
function s.black(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end
-- 서로 다른 두 장으로 백 1장·흑 1장을 맞출 수 있는가
function s.pair(g)
  for a in g:Iter() do
    if s.white(a) then
      for b in g:Iter() do
        if b~=a and s.black(b) then return true end
      end
    end
  end
  return false
end
