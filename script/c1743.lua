-- WDK13-011 羅星 エスキモ
-- 【出】《黒》《黒》：あなたのデッキを上から公開されたシグニのレベルの合計が４以上になるまで公開する。その中からシグニを２枚まで手札に加え、残りをトラッシュに置く。
-- 【起】《ターン１回》手札から＜宇宙＞のシグニを１枚以上捨てる：この方法で捨てたシグニのレベルの合計と同じレベルを持つ対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－12000する。
local s,id=GetID()
s.space=aux.ClassFilter(0,RACE_UCHU)  -- ＜宇宙＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{B}{B}")
  -- 합계 4가 되기 전에 덱이 떨어져도 공개한 것에서 고른다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local n,g,lv=0,nil,0
    repeat
      n=n+1
      g=Duel.GetDecktopGroup(tp,n)
      lv=0
      for x in g:Iter() do if x:IsSigni() then lv=lv+x:GetLevel() end end
    until lv>=4 or g:GetCount()<n
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local h=Duel.SelectCards(tp,g:Filter(Card.IsSigni,nil),0,2)
    if h:GetCount()>0 then Duel.SendToHand(h) end
    local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetMatchingGroup(s.space,tp,LOCATION_HAND,0,nil):GetCount()>0 end
    local g=Duel.SelectDiscard(tp,1,99,s.space)
    local lv=0
    for x in g:Iter() do lv=lv+x:GetLevel() end
    e:SetLabel(lv)
    Duel.SendToTrash(g,REASON_COST+REASON_DISCARD)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==e:GetLabel() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-12000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e3)
end
