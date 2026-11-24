-- WDK05-R01 来夢の巫女　リメンバ・ナイト
-- 【出】：対戦相手のすべてのシグニを凍結する。
-- 【起】《ターン１回》《コインアイコン》：カードを３枚引き、手札からカード２枚を好きな順番でデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do Duel.Freeze(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCoinCost(1)
  -- 처리 중에는 리프레시하지 않는다(FAQ 1·2)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,3)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    local n=math.min(2,g:GetCount())
    if n>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,Duel.SelectCards(tp,g,n,n)),false) end
  end)
  c:RegisterEffect(e2)
end
