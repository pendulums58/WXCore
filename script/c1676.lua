-- WDK09-001 奏世の鍵主　ウムル＝フィーラ
-- 【出】：対戦相手のシグニゾーン１つに【ゲート】１つを置く。カードを１枚引く。
-- 【自】：対戦相手のアタックフェイズ開始時、対戦相手はデッキの一番上を公開する。それが【ライフバースト】を持たない場合、
--         このターン、対戦相手は【ゲート】があるシグニゾーンにあるシグニでアタックできない。
-- 【起】《ゲーム１回》プライマル《コインアイコン》：対戦相手は、【ゲート】がある自分のシグニゾーンにあるすべてのシグニをデッキに加えてシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(s.gateop)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e2:SetRange(LOCATION_LRIG)
  e2:SetCondition(function(e,tp,eg,ep) return ep~=tp end)
  e2:SetOperation(s.revop)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1,true)
  e3:SetCoinCost(1)
  e3:SetOperation(s.primop)
  c:RegisterEffect(e3)
end
-- 【ゲート】는 존 하나에 하나까지(FAQ 1)
function s.gateop(e,tp)
  local zones={}
  for _,z in ipairs(Duel.GetSigniZones(1-tp)) do
    if not Duel.HasGate(z) then zones[#zones+1]=z end
  end
  local z=Duel.SelectZone(tp,zones)
  if z then Duel.PlaceGate(z) end
  Duel.Draw(tp,1)
end
function s.gated(c)
  local z=c:GetZone()
  return z~=nil and Duel.HasGate(z)
end
-- 공개한 카드는 확인 뒤 덱 맨 위에 뒷면으로 남는다(FAQ 2)
function s.revop(e,tp)
  local top=Duel.GetDecktopGroup(1-tp,1):GetFirst()
  if not top then return end
  Duel.RevealCards(top)
  if top:IsLifeBurst() then return end
  -- [の間] 「このターン」: 존에 거는 효과라 나중에 그 존에 나온 시그니도 어택할 수 없다(FAQ 4)
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_CANNOT_ATTACK)
  e1:SetTargetRange(0,LOCATION_SIGNI)
  e1:SetTarget(function(e,c) return s.gated(c) end)
  e1:SetReset(RESET_PHASE+PHASE_END)
  Duel.RegisterEffect(e1,tp)
end
-- 옮길 시그니가 없어도 섞는다(FAQ 6)
function s.primop(e,tp)
  Duel.SendToDeckShuffle(Duel.GetMatchingGroup(s.gated,tp,0,LOCATION_SIGNI,nil),1-tp)
end
