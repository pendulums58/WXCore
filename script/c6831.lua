-- WXK08-045 炎魔の赤釜　ウコバク
-- 【自】：このカードが【ビート】になったとき、あなたの＜悪魔＞のシグニ１体を対象とし、あなたの【ビート】が３枚の場合、《赤》を支払ってもよい。そうした場合、ターン終了時まで、それは【ダブルクラッシュ】を得る。
-- （【ダブルクラッシュ】を持つシグニがアタックによってダメージを与えた場合ライフクロスを１枚ではなく２枚クラッシュする）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BEAT)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_AKUMA) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and Duel.GetMatchingGroup(nil,tp,LOCATION_BEAT,0,nil):GetCount()==3) then return end
    if not (Duel.CanPayEna(tp,"{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}"),REASON_COST)
    aux.GrantKeyword(e,tc,EFFECT_DOUBLE_CRUSH)
  end)
  c:RegisterEffect(e1)
end
