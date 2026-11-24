-- WDK04-020 ウィッチ・ニッチ
-- 以下の２つから１つを選ぶ。
-- ①対象のあなたの＜トリック＞のシグニ１体を場からトラッシュに置く。そうした場合、あなたのトラッシュから対象の＜トリック＞のシグニ１枚を手札に加える。
-- ②【エナチャージ１】（あなたのデッキの一番上のカードをエナゾーンに置く）
local s,id=GetID()
s.trick=aux.ClassFilter(0,RACE_TRICK)  -- ＜トリック＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  -- ①은 장과 트래시의 시그니를 함께 고른다. 방금 놓은 것은 고를 수 없다(FAQ 1·3)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==1 then return end
    Duel.SelectTarget(tp,s.trick,tp,LOCATION_SZONE,0,1,1,nil)
    Duel.SelectTarget(tp,s.trick,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==1 then
      Duel.EnaCharge(tp,1)
      return
    end
    local mine,back
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then
        if tc:IsLocation(LOCATION_TRASH) then back=tc else mine=tc end
      end
    end
    if mine and Duel.SendToTrash(mine,REASON_EFFECT)>0 and back then Duel.SendToHand(back) end
  end)
  c:RegisterEffect(e1)
end
