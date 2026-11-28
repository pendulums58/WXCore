-- WXK10-026 水英の蒼天　モーセス
-- 【自】：このシグニがアタックしたとき、あなたのデッキの一番下のカードをトラッシュに置いてもよい。その後、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをこの方法でトラッシュに置かれたシグニのパワーと同じだけ－（マイナス）する。
-- 【起】《ターン１回》手札から青のシグニを１枚捨てる：対戦相手の手札を見て、この方法で捨てたシグニと同じパワーのシグニ１枚を選び、捨てさせる。
-- ライフバースト：対戦相手の手札を見て無色ではないカードを１枚選び、捨てさせる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    local p=0
    if Duel.SelectYesNo(tp) then
      local g=Duel.GetDeckbottomGroup(tp,1)
      local x=g:GetFirst()
      if x then Duel.SendToTrash(g,REASON_EFFECT) if x:IsSigni() then p=x:GetPower() end end
    end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc and p>0 then aux.AddPower(e,tc,-p) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_BLUE) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return g:GetCount()>0 end
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    e:SetLabel(x:GetPower())
    Duel.SendToTrash(x,REASON_COST+REASON_DISCARD)
  end)
  e2:SetOperation(function(e,tp,eg)
    local p=e:GetLabel()
    local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    Duel.ConfirmCards(tp,h)
    local g=h:Filter(function(x) return x:IsSigni() and x:GetPower()==p end,nil)
    if g:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    Duel.ConfirmCards(tp,h)
    local g=h:Filter(function(x) return x:GetColor()~=0 end,nil)
    if g:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD) end
  end)
  c:RegisterEffect(e9)
end
