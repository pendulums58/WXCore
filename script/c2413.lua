-- WX10-041 弩砲　ホイワス
-- 【出】：あなたのデッキの上からカードを２枚公開する。その中から＜アーム＞のシグニ１枚と＜ウェポン＞のシグニ１枚を手札に加え、残りを好きな順番でデッキの一番上に戻す。この方法でシグニを１枚も手札に加えていない場合、このシグニをダウンする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,2))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local got=0
    for _,f in ipairs({function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end,function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end}) do
      local x=Duel.SelectCards(tp,g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) and f(c) end,nil),0,1):GetFirst()
      if x and Duel.SendToHand(x)>0 then got=got+1 end
    end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then aux.ToDeckTopInOrder(tp,rest) end
    local h=e:GetHandler()
    if got==0 and h:IsLocation(LOCATION_SZONE) then Duel.Down(h) end
  end)
  c:RegisterEffect(e1)
end
