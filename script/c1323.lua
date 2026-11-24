-- WD21-008 震亜動地
-- このアーツを使用する際、手札から＜宇宙＞のシグニを１枚捨ててもよい。そうした場合、このアーツの使用コストは《赤×2》減る。
-- 以下の３つから１つを選ぶ。
-- ①カードを２枚引く。
-- ②あなたのデッキの上からカードを２枚エナゾーンに置く。
-- ③あなたのトラッシュからシグニを２枚まで対象とし、それらを手札に加え、手札を１枚捨てる。
local s,id=GetID()
s.uchu=aux.ClassFilter(0,RACE_UCHU)  -- ＜宇宙＞のシグニ
function s.initial_effect(c)
  local picked  -- 선언 때 고른 카드. 확정되면 코스트로 버린다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetMinCost(function(e,tp,base) return Duel.ReduceCost(base,"{R}{R}",math.min(1,s.hand(tp):GetCount())) end)
  e1:SetDeclare(function(e,tp)
    local base=Duel.GetUseCost()
    Duel.SetSelectCheck(function(g) return Duel.CanPayEna(tp,Duel.ReduceCost(base,"{R}{R}",g:GetCount())) end)
    picked=Duel.SelectCards(tp,s.hand(tp),0,1)
    Duel.SetUseCost(Duel.ReduceCost(base,"{R}{R}",picked:GetCount()))
    e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2)))
  end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SendToTrash(picked,REASON_COST+REASON_DISCARD)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==2 then Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,0,2,nil) end
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      Duel.Draw(tp,2)
    elseif e:GetLabel()==1 then
      Duel.EnaCharge(tp,2)
    else
      local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
      if g:GetCount()>0 then Duel.SendToHand(g) end
      aux.Discard(tp,1)
    end
  end)
  c:RegisterEffect(e1)
end
function s.hand(tp) return Duel.GetMatchingGroup(s.uchu,tp,LOCATION_HAND,0,nil) end
