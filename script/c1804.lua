-- WDK16-17 コードＶＬ　黒井しば
-- 【出】：あなたのデッキの一番上を公開する。それがレベル１の＜電機＞のシグニの場合、それを場に出す。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
s.denki=aux.ClassFilter(0,RACE_DENKI)  -- ＜電機＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,1)
    local tc=g:GetFirst()
    if not tc then return end
    Duel.RevealCards(g)
    if s.denki(tc) and tc:GetLevel()==1 then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
