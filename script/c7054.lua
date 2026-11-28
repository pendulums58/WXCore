-- WXK10-080 幻水　セベク
-- 【自】：このシグニがアタックしたとき、あなたの＜水獣＞のシグニ１体を対象とし、手札から＜水獣＞のシグニを２枚公開してもよい。そうした場合、ターン終了時まで、それのパワーを＋5000する。
-- 【自】：このカードがあなたの効果によって手札から公開されたとき、あなたの＜水獣＞のシグニ１体を対象とし、手札から《幻水　セベク》を１枚捨ててもよい。そうした場合、ターン終了時まで、それは「【常】：対戦相手のシグニの効果を受けない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local h=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end,tp,LOCATION_HAND,0,nil)
      if h:GetCount()<2 or not Duel.SelectYesNo(tp) then return end
      local g=Duel.SelectCards(tp,h,2,2)
      Duel.RevealCards(g)
      aux.AddPower(e,tc,5000)
    end
  end)
  c:RegisterEffect(e1)
  -- 【自】「このカードがあなたの効果によって手札から公開されたとき」는 아직
end
