-- WD22-012-G バッド・トイ
-- ベット―《コインアイコン》
-- 対象の対戦相手のレベル２以下のシグニ１体をトラッシュに置き、あなたのトラッシュから対象のレベル２以下の＜遊具＞のシグニ１枚を場に出す。あなたがベットしていた場合、代わりに対象の対戦相手のシグニ１体をトラッシュに置き、あなたのトラッシュから対象の＜遊具＞のシグニ１枚を場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local bet=Duel.IsBet()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (bet or x:GetLevel()<=2) end,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_YUGU) and (bet or x:IsLevelBetween(0,2)) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  -- 한쪽이 없어도 다른 쪽을 처리한다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local opp,mine
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then
        if tc:IsLocation(LOCATION_TRASH) then mine=tc else opp=tc end
      end
    end
    if opp then Duel.SendToTrash(opp,REASON_EFFECT) end
    if mine then Duel.PutOnField(mine,tp) end
  end)
  c:RegisterEffect(e1)
end
