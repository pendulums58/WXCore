-- PR-460 スピニング・フェイト（ウムルとタウィル 単行本 付録）
-- このアーツの使用コストはあなたのセンタールリグが＜タウィル＞の場合、《黒×1》減り、あなたのセンタールリグが＜ウムル＞の場合、《白×1》減る。
-- ターン終了時まで、対象の対戦相手のセンタールリグ１体は「【常】：アタックできない。」を得、対象の対戦相手のシグニ１体のパワーをー15000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 《開かれし極門　ウトゥルス》는 둘 다 줄어든다(FAQ 1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil)
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then
        if tc:IsSigni() then aux.AddPower(e,tc,-15000) else aux.GrantKeyword(e,tc,EFFECT_CANNOT_ATTACK) end  -- [まで] ターン終了時まで
      end
    end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if lc and lc:IsLrigType(LRIG_TAWIL) then base=Duel.ReduceCost(base,"{B}",1) end
    if lc and lc:IsLrigType(LRIG_UMR) then base=Duel.ReduceCost(base,"{W}",1) end
    return base
  end)
end
