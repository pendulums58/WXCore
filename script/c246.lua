-- PR-387 ライブ・スタート
-- ベット―《コインアイコン》
-- あなたのデッキからレベル４以下の白か黒のシグニ１枚を探してダウン状態で場に出し、デッキをシャッフルする。その後、あなたがベットしていた場合、追加であなたのトラッシュからこの方法で場に出したシグニのクロス条件に含まれるシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  -- 크로스 상태가 되게 낼 필요는 없다(FAQ 2). 코스트로 낸 카드도 된다(FAQ 3)
  e1:SetOperation(function(e,tp)
    local tc=aux.Search(tp,function(x) return x:IsSigni() and x:GetLevel()<=4 and (x:IsColor(COLOR_WHITE) or x:IsColor(COLOR_BLACK)) end,1):GetFirst()
    if tc then Duel.PutOnField(tc,tp,false,true) end
    aux.ShuffleDeck(tp)
    if not (Duel.IsBet() and tc and tc:IsLocation(LOCATION_SZONE)) then return end
    local partners=tc:GetCrossPartners()
    local x=Duel.SelectTarget(tp,function(c)
      if not c:IsSigni() then return false end
      for _,p in ipairs(partners) do if c:IsCardName(p) then return true end end
      return false
    end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if x then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e1)
end
