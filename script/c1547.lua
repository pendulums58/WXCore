-- WDK06-R07 火朝月夕
-- ベット―《コインアイコン》
-- あなたがベットする場合、このアーツの使用コストは《赤×1》《無×1》になる。
-- 対象の対戦相手のシグニ１体をバニッシュする。あなたのトラッシュから対象の赤のシグニ１枚を手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetBetCost("{R}{C}")
  -- 한쪽만 있어도 그쪽은 처리한다(FAQ 1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_RED) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then
        if tc:IsLocation(LOCATION_TRASH) then Duel.SendToHand(tc) else Duel.Banish(tc) end
      end
    end
  end)
  c:RegisterEffect(e1)
end
