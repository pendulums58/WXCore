-- WX04-035 不可解な誇超　コンテンポラ
-- 【常】：あなたの＜美巧＞のシグニは対戦相手の、ルリグとシグニの効果を受けない。
-- 【自】：このカードが対戦相手の効果によっていずれかの領域からトラッシュに置かれたとき、《緑》を支払ってもよい。そうした場合、このシグニを手札に加える。
-- ライフバースト：あなたのデッキの一番上のカードをエナゾーンに置く。その後、あなたのエナゾーンに＜美巧＞のシグニが５枚以上ある場合、あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 ライフバースト도(FAQ 3·10)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end)(x) end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and (sc:IsSigni() or sc:IsType(TYPE_LRIG)) end)
  c:RegisterEffect(e1)
  -- 어느 영역에서든(FAQ 1·2)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_TRASH)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp~=tp and r&REASON_EFFECT~=0 end)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_TRASH) and Duel.CanPayEna(tp,"{G}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
    if h:IsLocation(LOCATION_TRASH) then Duel.SendToHand(h) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,1)
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,tp,LOCATION_ENA,0,nil):GetCount()>=5 then
      local g=Duel.GetDecktopGroup(tp,1)
      if g:GetCount()>0 then Duel.SendToLife(g) end
    end
  end)
  c:RegisterEffect(e3)
end
