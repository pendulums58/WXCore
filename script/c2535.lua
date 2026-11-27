-- WX12-006 緑肆ノ遊　フリーフォール
-- 【出現条件】《メインフェイズアイコン》合計３枚の＜遊具＞のシグニをあなたの手札とエナゾーンからトラッシュに置く
-- 【自】《ターン１回》：このシグニがアタックしたとき、あなたのシグニ１体を対象とし、それをアップする。
-- 【自】：あなたのシグニ１体がアップ状態になったとき、このシグニをアップする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,3,function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end,LOCATION_HAND+LOCATION_ENA)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCountLimit(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Up(tc) end
  end)
  c:RegisterEffect(e1)
  -- 「アップ状態になったとき」(근사: 효과로 업했을 때는 EVENT 없음 → 자신의 어택 때만 처리된다)
end
