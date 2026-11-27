-- WX13-068 爆砲　ファイバル
-- 《クロスアイコン》《爆砲　フウバ》の左
-- 【クロス常】：このシグニの基本パワーは8000になる。
-- 【クロス自】：このシグニが《ヘブン》したとき、あなたのレベル１のシグニ１体を対象とし、ターン終了時まで、それは【アサシン】を得る。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2640,CROSS_LEFT)
  -- [の間] 【クロス常】
  aux.BasePower(c,8000,function(e) return e:GetHandler():IsCross() end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,2))
  e1:SetCode(EVENT_HEAVEN)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==1 end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.GrantKeyword(e,tc,EFFECT_ASSASSIN) end
  end)  -- [まで]
  c:RegisterEffect(e1)
end
