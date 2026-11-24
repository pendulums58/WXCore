-- WD22-014-UG バイオ・ハザード
-- ベット―《コインアイコン》《コインアイコン》
-- あなたのトラッシュから黒のシグニ１枚を対象とし、それを場に出す。あなたがベットしていた場合、代わりに黒のシグニ２枚を対象とし、それらを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local n=Duel.IsBet() and 2 or 1
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,n,n,nil)
  end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
    end
  end)
  c:RegisterEffect(e1)
end
