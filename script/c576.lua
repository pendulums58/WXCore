-- WX15-035 超罠　ハニトラ
-- 【自】：このシグニがアタックしたとき、このシグニと同じシグニゾーンにある【トラップ】１つを対象とし、それを表向きにし《トラップアイコン》を発動させる。
-- 【出】：あなたのデッキの上からカードを２枚見る。その中からカード１枚を【トラップ】としてあなたのシグニゾーンに設置してもよい。その後、残りを好きな順番でデッキの一番下に置く。
-- ライフバースト：対戦相手は手札を１枚捨てる。あなたの場に【トラップ】がある場合、追加で対象の対戦相手のシグニ１体をダウンする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:GetZone()==e:GetHandler():GetZone() end,tp,LOCATION_TRAP,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.OpenTrap(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g,0,1):GetFirst()
    if x then Duel.SetTrap(x,tp) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    aux.Discard(1-tp,1)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_TRAP,0,nil):GetCount()>0 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Down(tc) end
    end
  end)
  c:RegisterEffect(e3)
end
