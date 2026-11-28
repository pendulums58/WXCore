-- WDK16-13 コードＶＬ　出雲霞
-- 【出】：あなたのデッキの一番上を公開する。この方法でレベル２以下の＜電機＞のシグニが公開された場合、それを場に出してもよい。あなたの登録者数が１００万人を達成していて、この方法でシグニが公開された場合、それを場に出してもよい。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
s.denki=aux.ClassFilter(0,RACE_DENKI)  -- ＜電機＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  -- 내지 않으면 덱 위에 그대로
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,1)
    local tc=g:GetFirst()
    if not tc then return end
    Duel.RevealCards(g)
    if not tc:IsSigni() then return end
    if ((s.denki(tc) and tc:GetLevel()<=2) or Duel.GetSubscribers(tp)>=100) and Duel.SelectYesNo(tp) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
