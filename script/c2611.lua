-- WX13-037 幻蟲　スカラベ
-- 【自】：このシグニがバニッシュされたとき、対戦相手は自分のシグニ１体につき自分のデッキの上からカード１枚をそれらの【チャーム】にする。
-- 【自】：あなたの＜凶蟲＞のシグニ１体がアタックしたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－4000する。
-- 【出】：対戦相手の場にある【チャーム】２枚を対象とし、それらをトラッシュに置く。この方法で【チャーム】２枚がトラッシュに置かれなかった場合、このシグニを場からトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetOperation(function(e,tp)
    for x in Duel.GetMatchingGroup(Card.IsSigni,1-tp,LOCATION_SZONE,0,nil):Iter() do
      local top=Duel.GetDecktopGroup(1-tp,1):GetFirst()
      if top and not x:GetCharm() then Duel.Charm(top,x) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KYOUCHU)) end)(x) end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-4000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetOperation(function(e,tp)
    local cg=Group.CreateGroup()
    for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetCharm()~=nil end,tp,0,LOCATION_SZONE,nil):Iter() do cg:AddCard(x:GetCharm()) end
    local n=0
    if cg:GetCount()>=2 then n=Duel.SendToTrash(Duel.SelectCards(tp,cg,2,2),REASON_EFFECT) end
    local h=e:GetHandler()
    if n<2 and h:IsLocation(LOCATION_SZONE) then Duel.SendToTrash(h,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end
