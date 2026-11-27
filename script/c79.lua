-- WX12-Re10 純朴の光輝　アグライア
-- 【出】：あなたのデッキの上からカードを３枚公開する。この方法で＜天使＞のシグニが３枚公開された場合、その中から１枚を手札に加え、残りを好きな順番でデッキの一番上に戻す。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,3))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    if g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,nil):GetCount()>=3 then
      local x=Duel.SelectCards(tp,g,1,1)
      Duel.SendToHand(x)
    end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then aux.ToDeckTopInOrder(tp,rest) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
