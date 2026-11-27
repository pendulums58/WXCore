-- WX14-014 スティール・スペル・ラン
-- アンコール －《青》《無》
-- 対戦相手のトラッシュからスペル１枚を対象とし、それをあなたの手札にあるかのようにコストを支払わずに限定条件を無視して使用する。このターン、そのスペルがチェックゾーンから別の領域に移動される場合、代わりにゲームから除外される。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncoreCost("{U}{C}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) end,tp,0,LOCATION_TRASH,1,1,nil)
  end)
  -- 「代わりにゲームから除外」는 아직(근사)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.UseFree(tc,tp) end
  end)
  c:RegisterEffect(e1)
end
