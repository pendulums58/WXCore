-- WX13-045 轟左砲　ドーラ
-- 《クロスアイコン》《轟右砲　ドスラフ》の左
-- 【クロス自】：このシグニがアタックしたとき、あなたのレベル３以下のシグニ１体を対象とし、ターン終了時まで、それは【アサシン】を得る。
-- （【アサシン】を持つシグニがアタックすると正面のシグニとバトルをせず対戦相手にダメージを与える）
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,1413,CROSS_LEFT)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCondition(function(e) return e:GetHandler():IsCross() end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.GrantKeyword(e,tc,EFFECT_ASSASSIN) end
  end)  -- [まで]
  c:RegisterEffect(e1)
end
