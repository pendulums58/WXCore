-- WX08-024 羅石　サンスト
-- 《クロスアイコン》《羅石　ムンスト》の右
-- 【クロス常】：このシグニの基本パワーは15000になる。
-- 【起】手札から＜鉱石＞か＜宝石＞のシグニを合計３枚捨てる：あなたと対戦相手のライフクロス１枚をクラッシュする。
-- 【クロス自】：このシグニが《ヘブン》したとき、ターン終了時まで、このシグニは【アサシン】を得る。
-- ライフバースト：対戦相手のシグニのうち、最も小さいパワーを持つシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2283,CROSS_RIGHT)
  -- [の間] 【クロス常】
  aux.BasePower(c,15000,function(e) return e:GetHandler():IsCross() end)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(aux.DiscardCost(3,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end))
  e2:SetOperation(function(e,tp)
    Duel.Crush(tp,1)
    Duel.Crush(1-tp,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_HEAVEN)
  e3:SetRange(LOCATION_SZONE)
  e3:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_ASSASSIN) end  -- [まで]
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    local m
    for x in g:Iter() do if not m or x:GetPower()<m then m=x:GetPower() end end
    if m then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()==m end,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e4)
end
