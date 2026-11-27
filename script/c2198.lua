-- WX07-028 ＪＡＣＫＰＯＴ
-- このスペルを使用する際、あなたのアップ状態の＜原子＞のシグニを好きな数ダウンしてもよい。そうした場合、このカードの使用コストはこの方法でダウンしたシグニ１体につき《青×2》減る。
-- あなたのデッキから＜原子＞のシグニを３枚まで探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手のシグニを２体まで対象とし、手札から＜原子＞のシグニを３枚捨てる。そうした場合、それらをバニッシュする。
local s,id=GetID()
s.cut="{U}{U}"  -- 다운한 1체당 줄어드는 코스트
function s.initial_effect(c)
  local picked  -- 선언 때 고른 시그니. 확정되면 코스트로 다운한다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetMinCost(function(e,tp,base) return Duel.ReduceCost(base,s.cut,s.ups(tp):GetCount()) end)
  e1:SetDeclare(function(e,tp)
    local base=Duel.GetUseCost()
    Duel.SetSelectCheck(function(g) return Duel.CanPayEna(tp,Duel.ReduceCost(base,s.cut,g:GetCount())) end)
    picked=Duel.SelectCards(tp,s.ups(tp),0,5)
    Duel.SetUseCost(Duel.ReduceCost(base,s.cut,picked:GetCount()))
  end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if picked and picked:GetCount()>0 then Duel.Down(picked,REASON_COST) end
  end)
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,3)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==1 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil) end
  end)
  e2:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      Duel.Draw(tp,1)
      return
    end
    local h=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,tp,LOCATION_HAND,0,nil)
    if h:GetCount()<3 then return end
    if Duel.SendToTrash(Duel.SelectCards(tp,h,3,3),REASON_EFFECT+REASON_DISCARD)<3 then return end
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e2)
end
function s.ups(tp) return Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end)(x) and x:IsUp() end,tp,LOCATION_SZONE,0,nil) end
