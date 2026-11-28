-- WXEX1-73 金銭の慈愛　マモン
-- 【起】《ダウン》：あなたのデッキの一番上のカードをこのシグニの【チャーム】にする。
-- 【起】あなたの場にある【チャーム】１枚をトラッシュに置く：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－3000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp)
    local top=Duel.GetDecktopGroup(tp,1):GetFirst()
    local h=e:GetHandler()
    if top and h:IsLocation(LOCATION_SZONE) then Duel.Charm(top,h) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local pool=Group.CreateGroup()
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
      local ch=x:GetCharm()
      if ch then pool:AddCard(ch) end
    end
    if chk==0 then return pool:GetCount()>0 end
    local pick=Duel.SelectCards(tp,pool,1,1)
    if pick:GetCount()>0 then Duel.SendToTrash(pick,REASON_COST) end
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-3000) end
  end)
  c:RegisterEffect(e2)
end
