-- WDK12-022 修習
-- 以下の２つから１つを選ぶ。
-- ①対象のあなたの＜微菌＞のシグニ１体を場からトラッシュに置く。そうした場合、あなたのエナゾーンから対象のシグニ１枚を手札に加える。
-- ②【エナチャージ１】（あなたのデッキの一番上のカードをエナゾーンに置く）
local s,id=GetID()
s.germ=aux.ClassFilter(0,RACE_BIKIN)  -- ＜微菌＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  -- 모드를 고른 뒤 처리 직전에 두 대상을 함께 고른다(FAQ 1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then
      Duel.SelectTarget(tp,s.germ,tp,LOCATION_SZONE,0,1,1,nil)
      Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_ENA,0,1,1,nil)
    end
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==1 then Duel.EnaCharge(tp,1) return end
    local f,en
    for tc in Duel.GetTargets():Iter() do
      if tc:IsLocation(LOCATION_SZONE) then f=f or tc elseif tc:IsLocation(LOCATION_ENA) then en=en or tc end
    end
    -- 「そうした場合」
    if not (f and f:IsRelateToEffect(e) and Duel.SendToTrash(f,REASON_EFFECT)>0) then return end
    if en and en:IsRelateToEffect(e) then Duel.SendToHand(en) end
  end)
  c:RegisterEffect(e1)
end
