-- WDK-F03-17 偉智の遊　ユキソリ
-- 【出】：あなたのデッキの上からカードを３枚見る。それらを好きな順番でデッキの一番上に戻す。（デッキが２枚以下の場合それらをすべて見る）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
function s.op(e,tp)
  local g=Duel.GetDecktopGroup(tp,3)
  if g:GetCount()==0 then return end
  Duel.ConfirmCards(tp,g)
  s.totop(tp,g)
end
-- 고른 순서대로 덱 위에 돌려놓는다(처음 고른 카드가 맨 위)
function s.totop(tp,g)
  local list={}
  for c in Duel.SelectOrder(tp,g):Iter() do list[#list+1]=c end
  for i=#list,1,-1 do Duel.SendToDeckPosition(list[i],1) end
end
