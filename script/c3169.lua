-- WX21-002 雪月華　遊月・参
-- 【常】：あなたのグロウフェイズをスキップする。
-- 【自】：あなたのアタックフェイズ開始時、あなたのデッキの一番上のカードをエナゾーンに置く。その後、あなたのエナゾーンから＜龍獣＞のシグニを１枚まで対象とし、それを手札に加える。
-- 【起】《ターン１回》《赤》《緑》：あなたのデッキの上からカードを５枚公開する。その中から＜龍獣＞のシグニを２枚まで手札に加え、残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_SKIP_GROW)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(1,0)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e2:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,1)
    local x=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,tp,LOCATION_ENA,0,0,1,nil):GetFirst()
    if x then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1)
  e3:SetEnaCost("{R}{G}")
  e3:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,5))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local x=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,nil),0,2)
    if x:GetCount()>0 then Duel.SendToHand(x) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end
