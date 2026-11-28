-- WDK17-022 アクター・ワードローブ
-- 以下の２つから１つを選ぶ。
-- ①対象のあなたの＜美巧＞のシグニ１体を場からトラッシュに置く。そうした場合、あなたのトラッシュから対象の＜美巧＞のシグニ１枚を手札に加える。
-- ②【エナチャージ１】（あなたのデッキの一番上のカードをエナゾーンに置く）
local s,id=GetID()
s.bikou=aux.ClassFilter(0,RACE_BIKOU)  -- ＜美巧＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  -- 처리 직전에 두 대상을 함께 고른다(FAQ 1). 트래시에 둔 시그니는 가져올 수 없다(FAQ 2)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then
      Duel.SelectTarget(tp,s.bikou,tp,LOCATION_SZONE,0,1,1,nil)
      Duel.SelectTarget(tp,s.bikou,tp,LOCATION_TRASH,0,1,1,nil)
    end
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==1 then Duel.EnaCharge(tp,1) return end
    local f,tr
    for tc in Duel.GetTargets():Iter() do
      if tc:IsLocation(LOCATION_SZONE) then f=f or tc elseif tc:IsLocation(LOCATION_TRASH) then tr=tr or tc end
    end
    if not (f and f:IsRelateToEffect(e) and Duel.SendToTrash(f,REASON_EFFECT)>0) then return end
    if tr and tr:IsRelateToEffect(e) then Duel.SendToHand(tr) end
  end)
  c:RegisterEffect(e1)
end
