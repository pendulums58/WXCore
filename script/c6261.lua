-- WXK01-079 コードライド　タチスク
-- 【自】：あなたのシグニ１体がドライブ状態になったとき、対戦相手のパワー1000以下のシグニ１体を対象とし、《赤》を支払ってもよい。そうした場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 한꺼번에 2체면 2번(FAQ 2)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_DRIVE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:IsSigni() and x:GetControler()==tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=1000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.CanPayEna(tp,"{R}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}"),REASON_COST)
      if tc:GetPower()<=1000 then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e1)
end
