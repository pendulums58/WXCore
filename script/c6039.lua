-- WXEX1-05 ドーナ　ＦＯＵＲＴＨ＋＋
-- 【出】：あなたのデッキから【レイヤー】を持つシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。
-- 【起】《ターン１回》《メインフェイズアイコン》《アタックフェイズアイコン》《コインアイコン》《コインアイコン》：あなたのデッキから【レイヤー】を持つシグニ１枚を探して場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,aux.HasLayer,2)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetCountLimit(1)
  e2:SetCoinCost(2)
  e2:SetOperation(function(e,tp)
    local tc=aux.Search(tp,aux.HasLayer,1):GetFirst()
    if tc then Duel.PutOnField(tc,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
end
