-- SP38-003 ロック・テンカウント（「ウィクロス 10th Anniversary Book」付録）
-- このアーツを使用する際、手札から青のカードを３枚まで捨てる。このアーツの使用コストはこの方法で捨てたカード１枚につき《青×1》減る。
-- このターン、対戦相手は手札を３枚捨てないかぎりシグニでアタックできない。（アタックするごとに捨てる）
local s,id=GetID()
function s.blue(tp) return Duel.GetMatchingGroup(function(x) return x:IsColor(COLOR_BLUE) end,tp,LOCATION_HAND,0,nil) end
function s.initial_effect(c)
  local picked  -- 선언 때 고른 카드. 확정되면 버린다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetMinCost(function(e,tp,base) return Duel.ReduceCost(base,"{U}",math.min(3,s.blue(tp):GetCount())) end)
  e1:SetDeclare(function(e,tp)
    local base=Duel.GetUseCost()
    Duel.SetSelectCheck(function(g) return Duel.CanPayEna(tp,Duel.ReduceCost(base,"{U}",g:GetCount())) end)
    picked=Duel.SelectCards(tp,s.blue(tp),0,3)
    Duel.SetUseCost(Duel.ReduceCost(base,"{U}",picked:GetCount()))
  end)
  -- 코스트로 버린 것이다(FAQ 2)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if picked:GetCount()>0 then Duel.SendToTrash(picked,REASON_COST+REASON_DISCARD) end
  end)
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン」 「手札を３枚捨てないかぎりアタックできない」(근사: 어택할 때 버리지 않으면 무효. 어택할지는 상대가 정한다, FAQ 1)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_ATTACK)
    e1:SetCondition(function(e2,tp2,eg) local x=eg:GetFirst() return x:IsSigni() and x:GetControler()~=tp end)
    e1:SetOperation(function()
      local p=1-tp
      local h=Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil)
      if h:GetCount()>=3 and Duel.SelectYesNo(p) then
        Duel.SendToTrash(Duel.SelectCards(p,h,3,3),REASON_COST+REASON_DISCARD)
      else
        Duel.NegateAttack()
      end
    end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
