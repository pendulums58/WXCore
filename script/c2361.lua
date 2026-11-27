-- WX09-037 ウトゥルス・ゲート
-- あなたのセンタールリグがレベル５以上の場合、このカードの使用コストは《無×2》減る。
-- あなたのセンタールリグより低いレベルを持つ対象の対戦相手のシグニ１体をトラッシュに置き、あなたのトラッシュからあなたのセンタールリグより低いレベルを持つ対象のシグニ１枚を場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return (lc and lc:GetLevel()>=5) and Duel.ReduceCost(base,"{C}",2) or base end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local lv=lc and lc:GetLevel() or 0
    s.a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<lv end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    s.b=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<lv end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
  end)
  e1:SetOperation(function(e,tp)
    if s.a and s.a:IsRelateToEffect(e) then Duel.SendToTrash(s.a,REASON_EFFECT) end
    if s.b and s.b:IsRelateToEffect(e) then Duel.PutOnField(s.b,tp) end
  end)
  c:RegisterEffect(e1)
end
