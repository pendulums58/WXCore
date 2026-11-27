-- WX11-086 復讐の右魔　メガイラ
-- 《クロスアイコン》《復讐の左魔　ティシポネ》の右
-- 【クロス常】：このシグニの基本パワーは5000になる。
-- 【クロス出】：対戦相手のシグニ１体を対象としターン終了時まで、それのパワーを－2000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2529,CROSS_RIGHT)
  -- [の間] 【クロス常】
  aux.BasePower(c,5000,function(e) return e:GetHandler():IsCross() end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,2))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e) return e:GetHandler():IsCross() end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-2000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e1)
end
