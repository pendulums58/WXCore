-- WDK16-05T 美兎サポーター　凛＆楓
-- 【常】：このキーはあなたのセンタールリグが《月ノ美兎　レベル４》の場合にしか新たに場に出すことができない。
-- 【出】：対戦相手のシグニを２体まで対象とし、それらをバニッシュする。カードを１枚引く。登録者数を２０万人得る。
-- 【起】《アタックフェイズアイコン》《青》《青》《赤》《赤》このキーを場からルリグトラッシュに置く：対戦相手のすべてのシグニをバニッシュする。カードを３枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetCode(EFFECT_CANNOT_PLAY)
  e1:SetCondition(function(e)
    local lc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LRIG,0,nil):GetFirst()
    return not (lc and lc:IsCardName(1783))
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
    Duel.Draw(tp,1)
    Duel.AddSubscribers(tp,20)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_KEY)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetEnaCost("{U}{U}{R}{R}")
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
    Duel.Draw(tp,3)
  end)
  c:RegisterEffect(e3)
end
