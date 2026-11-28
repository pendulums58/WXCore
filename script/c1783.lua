-- WDK16-01T 月ノ美兎　レベル４
-- 【常】：あなたが《赤》か《青》を支払う際、代わりに《白》を支払ってもよい。
-- 【自】：このルリグがアタックしたとき、登録者数を１０万人得る。
-- 【出】：あなたのデッキからシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- 【起】《ゲーム１回》＃みとの生放送《白×0》：対戦相手のシグニ１体を対象とし、それをトラッシュに置く。あなたの登録者数が１００万人を達成している場合、あなたのデッキからシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  -- [の間] 【常】 내 흰 에나를 《赤》·《青》로도 낼 수 있다
  e1:SetCode(EFFECT_ADD_PAY_COLOR)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_ENA,0)
  e1:SetTarget(function(e,x) return x:IsColor(COLOR_WHITE) end)
  e1:SetValue(COLOR_RED)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,0))
  e2:SetCode(EFFECT_ADD_PAY_COLOR)
  e2:SetRange(LOCATION_LRIG)
  e2:SetTargetRange(LOCATION_ENA,0)
  e2:SetTarget(function(e,x) return x:IsColor(COLOR_WHITE) end)
  e2:SetValue(COLOR_BLUE)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,1))
  e3:SetCode(EVENT_ATTACK)
  e3:SetOperation(function(e,tp)
    Duel.AddSubscribers(tp,10)
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e4:SetDescription(aux.Ability(id,2))
  e4:SetCode(EVENT_ON_PLAY)
  e4:SetOperation(function(e,tp)
    local g=aux.Search(tp,Card.IsSigni,1)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e4)
  local e5=Effect.CreateEffect(c)
  e5:SetType(EFFECT_TYPE_IGNITION)
  e5:SetDescription(aux.Ability(id,3))
  e5:SetRange(LOCATION_LRIG)
  e5:SetCountLimit(1,true)
  e5:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e5:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
    if Duel.GetSubscribers(tp)>=100 then
    local g=aux.Search(tp,Card.IsSigni,2)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
    end
  end)
  c:RegisterEffect(e5)
end
