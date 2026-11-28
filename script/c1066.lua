-- WDK16-22 チャイルド・クッキー
-- 以下の２つから１つを選ぶ。
-- ①対象のあなたの＜電機＞のシグニ１体を場からトラッシュに置く。そうした場合、対戦相手は対象の自分のシグニ１体を手札に戻す。
-- ②【エナチャージ１】（あなたのデッキの一番上のカードをエナゾーンに置く）
local s,id=GetID()
s.denki=aux.ClassFilter(0,RACE_DENKI)  -- ＜電機＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  -- 내 ＜電機＞과 상대가 고르는 상대 시그니를 함께 대상으로 한다
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then
      Duel.SelectTarget(tp,s.denki,tp,LOCATION_SZONE,0,1,1,nil)
      Duel.SelectTarget(1-tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    end
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==1 then Duel.EnaCharge(tp,1) return end
    local mine,opp
    for tc in Duel.GetTargets():Iter() do
      if tc:GetControler()==tp then mine=mine or tc else opp=opp or tc end
    end
    -- 「そうした場合」
    if not (mine and mine:IsRelateToEffect(e) and Duel.SendToTrash(mine,REASON_EFFECT)>0) then return end
    if opp and opp:IsRelateToEffect(e) then Duel.SendToHand(opp) end
  end)
  c:RegisterEffect(e1)
end
