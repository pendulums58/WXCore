-- WDK17-007 オクロック・ベル
-- ベット―《コインアイコン》《コインアイコン》（このアーツを使用する際に《コインアイコン》《コインアイコン》を支払ってもよい）
-- 対戦相手のトラッシュからシグニ１枚を対象とし、それを傀儡状態であなたの場に出す。あなたがベットしていた場合、代わりに対戦相手のトラッシュからシグニ２枚を対象とし、それらを傀儡状態であなたの場に出す。
-- （傀儡状態のシグニが場を離れる場合、代わりに持ち主のトラッシュに置かれる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  -- 레벨·리미트·한정 조건은 지킨다(FAQ). 【出】은 내 쪽에 나온 것으로 발동한다
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_TRASH,1,Duel.IsBet() and 2 or 1,nil)
  end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_TRASH) then Duel.PutOnField(tc,tp) end
    end
  end)
  c:RegisterEffect(e1)
end
