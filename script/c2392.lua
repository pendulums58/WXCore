-- WX10-013 エルドラ×マークIII＋
-- 【起】《ターン１回》《アタックフェイズアイコン》《青×0》：あなたの＜水獣＞のシグニ１体を対象とし、ターン終了時まで、それのパワーを＋1000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetTiming(TIMING_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,1000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e1)
end
