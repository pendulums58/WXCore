-- PR-466 懐古の巫女　タマヨリヒメ（コロコロアニキ2018年夏号 付録）
-- 【常】：あなたの白のシグニのパワーを＋1000する。
-- 【自】：あなたの《新鋭の巫女　タマヨリヒメ》が場に出たとき、対戦相手のすべてのシグニを手札に戻す。
-- 【起】《ターン１回》《白×0》：あなたの手札からコストの合計が５以下のスペル１枚をコストを支払わずに使用する。この能力はあなたの場に《新鋭の巫女　タマヨリヒメ》がいる場合にしか使用できない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end)
  e1:SetValue(1000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetRange(LOCATION_LRIG)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:GetCode()==350 end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1)
  e3:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:GetCode()==350 end,e:GetHandlerPlayer(),LOCATION_KEY+LOCATION_SZONE,0,nil):GetCount()>0 end)
  -- 다른 효과로 늘어난 코스트는 낸다(FAQ 1): 인쇄 코스트만 없앤다
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) and x:GetCostTotal()<=5 end,tp,LOCATION_HAND,0,nil)
    local tc=Duel.SelectCards(tp,g,1,1):GetFirst()
    if tc then Duel.UseFree(tc,tp) end
  end)
  c:RegisterEffect(e3)
end
