-- WXK01-039 魔海の鉤爪　キャプテン・フック
-- 【常】：あなたの手札が０枚であるかぎり、このシグニは対戦相手の効果によってバニッシュされない。
-- 【出】手札を２枚捨てる：あなたのデッキの上からカードを５枚公開する。その中から＜悪魔＞のシグニを２枚まで場に出し、残りをトラッシュに置く。
-- ライフバースト：対戦相手のシグニを２体まで対象とし、それらをダウンし凍結する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】 효과 바니시만(FAQ 1·2)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_BANISH_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()==0 end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(aux.DiscardCost(2))
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    for x in Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and x:IsClass(0,RACE_AKUMA) end,nil),0,2):Iter() do Duel.PutOnField(x,tp) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    for x in Duel.GetTargets():Iter() do
      if x:IsRelateToEffect(e) then Duel.Down(x) Duel.Freeze(x) end
    end
  end)
  c:RegisterEffect(e9)
end
