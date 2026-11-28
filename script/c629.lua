-- SP38-005 ダーク・テンペスト（「ウィクロス 10th Anniversary Book」付録）
-- 対戦相手のターンの間、あなたのセンタールリグのレベルが対戦相手より低い場合、このアーツは《アタックフェイズアイコン》を得、このアーツの使用コストは《黒×2》《無×2》増える。
-- 対戦相手のルリグ１体を対象とし、ターン終了時まで、それのレベルを－１する。
local s,id=GetID()
-- 상대 턴이고 내 센터 레벨이 더 낮은가
function s.lower(tp)
  local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
  local oc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
  return Duel.GetTurnPlayer()~=tp and lc and oc and lc:GetLevel()<oc:GetLevel()
end
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 《アタックフェイズアイコン》은 DB에 넣고 여기서 막는다
  e1:SetCondition(function(e,tp) return Duel.GetPhase()~=PHASE_ATTACK or s.lower(tp) end)
  aux.SetCostBy(e1,function(e,tp,base) if s.lower(tp) then return base.."{B}{B}{C}{C}" end return base end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG+LOCATION_ASSIST,1,1,nil)
  end)
  -- 레벨 말고는 그대로(FAQ 1). 넘친 시그니는 룰 처리로(FAQ 2)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    -- [まで] ターン終了時まで
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_LEVEL)
    e1:SetValue(-1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
  end)
  c:RegisterEffect(e1)
end
