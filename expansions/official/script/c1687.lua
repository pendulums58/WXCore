-- WDK09-015 コードメイズ　バンクバ
-- 【起】《ターン１回》《メインフェイズアイコン》《アタックフェイズアイコン》《青×0》：対戦相手のトラッシュから対象のカード１枚をデッキの一番下に置く。
--   そうした場合、対象のシグニ１体を他のシグニゾーンに配置してもよい。（既にシグニのあるシグニゾーンには配置できない）
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e1:SetCountLimit(1)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.EnaCharge(tp,1) end)
  c:RegisterEffect(e2)
end
-- 트래시가 비어 있어도 쓸 수 있다(FAQ 1). 옮길 시그니는 양쪽 다 된다(FAQ 2)
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local t=Duel.SelectTarget(tp,nil,tp,0,LOCATION_TRASH,1,1,nil):GetFirst()
  e:SetLabel(t and 1 or 0)
  Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
end
function s.op(e,tp)
  local trash, signi
  for tc in Duel.GetTargets():Iter() do
    if tc:IsSigni() and tc:IsLocation(LOCATION_SZONE) then signi=tc else trash=trash or tc end
  end
  if e:GetLabel()==0 then signi=signi or trash; trash=nil end
  -- 「Aする。そうした場合Bする」: 덱 아래에 놓지 못했으면 옮기지 않는다(FAQ 1)
  if not (trash and trash:IsRelateToEffect(e) and trash:IsLocation(LOCATION_TRASH)) then return end
  Duel.SendToDeckBottom(trash,false)
  if not trash:IsLocation(LOCATION_MDECK) then return end
  if not (signi and signi:IsRelateToEffect(e)) then return end
  -- 자기 시그니는 자기 존에, 상대 시그니는 상대 존에만(FAQ 3)
  local zones={}
  for _,z in ipairs(Duel.GetSigniZones(signi:GetControler())) do
    if z~=signi:GetZone() and Duel.GetMatchingGroup(function(x) return x:GetZone()==z end,tp,LOCATION_SZONE,LOCATION_SZONE,nil):GetCount()==0 then
      zones[#zones+1]=z
    end
  end
  if #zones>0 and Duel.SelectYesNo(tp) then Duel.MoveSigni(signi,Duel.SelectZone(tp,zones)) end
end
