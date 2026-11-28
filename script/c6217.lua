-- WXK01-034 ダーク・トゥインクル
-- ベット―《コインアイコン》
-- あなたがベットする場合、このアーツの使用コストは《黒×1》になる。
-- 対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－15000する。（パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetBetCost("{B}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-15000)  -- [まで] ターン終了時まで
    end
  end)
  c:RegisterEffect(e1)
end
