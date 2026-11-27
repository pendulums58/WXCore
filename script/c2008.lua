-- WX04-021 辛苦の閻魔　ウリス
-- 【起】《ターン１回》あなたの場にある【チャーム】１枚をトラッシュに置く：各プレイヤーは自分のデッキの上からカードを３枚トラッシュに置く。
-- 【起】《ターン１回》あなたの場にある【チャーム】２枚をトラッシュに置く：あなたのトラッシュから黒のシグニ１枚を対象とし、それを手札に加える。
-- 【起】あなたの場にある【チャーム】３枚をトラッシュに置く：対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Group.CreateGroup()
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
      if x:GetCharm() then g:AddCard(x:GetCharm()) end
    end
    if chk==0 then return g:GetCount()>=1 end
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    for x in Duel.GetDecktopGroup(1-tp,3):Iter() do g:AddCard(x) end
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Group.CreateGroup()
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
      if x:GetCharm() then g:AddCard(x:GetCharm()) end
    end
    if chk==0 then return g:GetCount()>=2 end
    Duel.SendToTrash(Duel.SelectCards(tp,g,2,2),REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Group.CreateGroup()
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
      if x:GetCharm() then g:AddCard(x:GetCharm()) end
    end
    if chk==0 then return g:GetCount()>=3 end
    Duel.SendToTrash(Duel.SelectCards(tp,g,3,3),REASON_COST)
  end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(aux.BanishOp)
  c:RegisterEffect(e3)
end
