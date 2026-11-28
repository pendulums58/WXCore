-- WXK05-071 幻水　プロテロ
-- 【出】：あなたの＜水獣＞のシグニ１体を対象とし、手札から＜水獣＞のシグニを３枚公開してもよい。そうした場合、ターン終了時まで、それは【ランサー】を得る。
-- （【ランサー】を持つシグニがバトルでシグニをバニッシュしたとき、対戦相手のライフクロスを１枚クラッシュする）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if Duel.SelectYesNo(tp) and aux.RevealFromHand(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end,3):GetCount()==3 then aux.GrantKeyword(e,tc,EFFECT_LANCER) end
    end
  end)
  c:RegisterEffect(e1)
end
