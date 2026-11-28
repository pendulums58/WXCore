-- WDK16-01S 静凛　レベル４
-- 【自】：あなたのターン終了時、あなたの手札が３枚以上ある場合、登録者数を１０万人得る。
-- 【出】：カードを２枚引く。
-- 【起】《ゲーム１回》＃しずりん生放送《青×0》：あなたの登録者数が７０万人を達成している場合、対戦相手は手札を２枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()>=3 end)
  e1:SetOperation(function(e,tp)
    Duel.AddSubscribers(tp,10)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1,true)
  e3:SetOperation(function(e,tp)
    if Duel.GetSubscribers(tp)>=70 then aux.Discard(1-tp,2) end
  end)
  c:RegisterEffect(e3)
end
