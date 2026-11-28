-- WDK16-05H 楓サポーター　凛＆美兎
-- 【常】：このキーはあなたのセンタールリグが《樋口楓　レベル４》の場合にしか新たに場に出すことができない。
-- 【出】：対戦相手の手札を見て１枚選び、捨てさせる。あなたのデッキから＜電機＞のシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。登録者数を２０万人得る。
-- 【起】《アタックフェイズアイコン》このキーを場からルリグトラッシュに置く：対戦相手のセンタールリグとすべてのシグニをダウンする。
local s,id=GetID()
s.denki=aux.ClassFilter(0,RACE_DENKI)  -- ＜電機＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetCode(EFFECT_CANNOT_PLAY)
  e1:SetCondition(function(e)
    local lc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LRIG,0,nil):GetFirst()
    return not (lc and lc:IsCardName(1781))
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  -- 상대 패를 보고 골라 버리게 한다
  e2:SetOperation(function(e,tp)
    local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if h:GetCount()>0 then
      Duel.ConfirmCards(tp,h)
      Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD)
    end
    local g=aux.Search(tp,s.denki,2)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
    Duel.AddSubscribers(tp,20)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_KEY)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    for x in Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):Iter() do g:AddCard(x) end
    for x in g:Iter() do Duel.Down(x) end
  end)
  c:RegisterEffect(e3)
end
