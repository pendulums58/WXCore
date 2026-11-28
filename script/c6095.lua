-- WXEX1-61 勝利の国王　シャルル
-- 【出】《赤》：あなたのトラッシュから《ライズアイコン》を持つシグニ１枚を対象とし、それを手札に加える。
-- 【起】《ターン１回》あなたのシグニの下からカード１枚をトラッシュに置く：対戦相手のパワー8000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{R}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local ug=Group.CreateGroup()
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
      for u in x:GetUnderGroup():Iter() do ug:AddCard(u) end
    end
    if chk==0 then return ug:GetCount()>0 end
    local pick=Duel.SelectCards(tp,ug,1,1)
    if pick:GetCount()>0 then Duel.SendToTrash(pick,REASON_COST) end
  end)
  e2:SetTarget(aux.BanishPowerTarget(8000))
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
end
