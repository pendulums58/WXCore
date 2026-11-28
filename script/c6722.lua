-- WXK07-024 ナナシ　鍵ノ型
-- 【出】：あなたのデッキの上からカードを４枚公開する。その中から黒のカードを３枚まで選び、それぞれ手札に加えるかエナゾーンに置き、残りをトラッシュに置く。
-- 【起】《アタックフェイズアイコン》このキーを場からルリグトラッシュに置く：あなたのトラッシュからレベル２以下のシグニ１枚を対象とし、それを場に出す。それの【出】能力は発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    for x in Duel.SelectCards(tp,g:Filter(function(y) return y:IsColor(COLOR_BLACK) end,nil),0,3):Iter() do
      if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.SendToHand(x) else Duel.SendToEna(x) end
    end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=2 end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.PutOnField(tc,tp,true)
    end
  end)
  c:RegisterEffect(e2)
end
