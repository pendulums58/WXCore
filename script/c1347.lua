-- WD22-019-U 破戒の轟牙　シヴァ
-- 【常】：あなたの手札が０枚であるかぎり、このシグニの基本パワーは18000になる。
-- 【起】《ダウン》：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－10000する。この能力はあなたの手札が０枚の場合にしか使用できない。
-- 【起】手札をすべて捨てる：この方法であなたがカードを４枚以上捨てた場合、あなたのデッキの一番上のカードをライフクロスに加える。
-- ライフバースト：あなたの手札をすべて捨てる。その後、あなたのトラッシュから黒のシグニを３枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,18000,function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_HAND,0,nil):GetCount()==0 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_HAND,0,nil):GetCount()==0 end)
  e1:SetCost(aux.SelfDownCost)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-10000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    e:SetLabel(g:GetCount())
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_COST+REASON_DISCARD) end
  end)
  e2:SetOperation(function(e,tp)
    if e:GetLabel()>=4 then Duel.SendToLife(Duel.GetDecktopGroup(tp,1)) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD) end
    -- 방금 버린 카드도 대상이 된다(「その後」)
    g=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,0,3,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e3)
end
