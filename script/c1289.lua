-- WD19-001 ナナシ　其ノ四
-- 【出】《コインアイコン》：あなたのトラッシュから黒のシグニを２枚まで対象とし、それらを手札に加える。
-- 【起】《ターン１回》《黒×0》：対戦相手の場にある【ウィルス】を好きな数取り除く。その後、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをこの方法で取り除いた【ウィルス】１つにつき－10000する。
local s,id=GetID()
function s.initial_effect(c)
  -- 코인은 1개만 낼 수 있고 2장까지다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCoinCost(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.black,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetOperation(s.virusop)
  c:RegisterEffect(e2)
end
function s.black(c) return c:IsSigni() and c:IsColor(COLOR_BLACK) end
-- 몇 개 치울지 정하고 존을 하나씩 고른다. 그 뒤 대상 1체만 －(FAQ 2: 여러 체에 나눌 수 없다)
function s.virusop(e,tp)
  local zones={}
  for _,z in ipairs(Duel.GetSigniZones(1-tp)) do
    if Duel.HasVirus(z) then zones[#zones+1]=z end
  end
  local n=#zones>0 and Duel.AnnounceNumber(tp,0,#zones) or 0
  local removed=0
  for _=1,n do
    local left={}
    for _,z in ipairs(zones) do if Duel.HasVirus(z) then left[#left+1]=z end end
    local z=Duel.SelectZone(tp,left)
    if z and Duel.RemoveVirus(z) then removed=removed+1 end
  end
  local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
  if tc and removed>0 then
    -- [まで] ターン終了時まで
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_POWER)
    e1:SetValue(-10000*removed)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
  end
end
