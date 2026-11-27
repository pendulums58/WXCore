-- WX08-031 大幻蟲　ヘラカブト
-- 【常】：対戦相手のシグニのパワーを、対戦相手の場にある【チャーム】１枚につき－2000する。
-- 【自】：あなたのレゾナ１体が場に出たとき、ターン終了時まで、【チャーム】が付いている対戦相手のすべてのシグニのパワーを－5000する。
-- ライフバースト：あなたのトラッシュから対象の＜凶蟲＞のシグニ１枚を手札に加える。対戦相手の場に【チャーム】がある場合、追加であなたのトラッシュから対象のカード１枚を手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,LOCATION_SZONE)
  e1:SetTarget(function(e,x) return x:IsSigni() end)
  e1:SetValue(function(e) return -2000*(function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do if x:GetCharm() then n=n+1 end end return n end)(1-e:GetHandlerPlayer()) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:IsType(TYPE_RESONA) end)
  -- [まで] 처리할 때
  e2:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetCharm()~=nil end,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,-5000) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KYOUCHU)) end,tp,LOCATION_TRASH,0,1,1,nil)
    if (function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do if x:GetCharm() then n=n+1 end end return n end)(1-tp)>0 then Duel.SelectTarget(tp,nil,tp,LOCATION_TRASH,0,1,1,nil) end
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e3)
end
