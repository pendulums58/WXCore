-- WXK10-040 羅原魔　デーモンコア
-- 【自】：あなたのターンの間、あなたの効果１つによってあなたがカードを１枚以上引いたとき、ターン終了時まで、このシグニのパワーを＋1000する。
-- 【自】：このシグニがアタックしたとき、このシグニよりパワーの低い対戦相手のシグニ１体を対象とし、手札から赤のシグニを１枚捨ててもよい。そうした場合、それをバニッシュする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_DRAW)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return ep==tp and Duel.GetTurnPlayer()==tp and (r&REASON_EFFECT)~=0 end)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,1000) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local p=e:GetHandler():GetPower()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<p end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local h=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_RED) end,tp,LOCATION_HAND,0,nil)
      if h:GetCount()>0 and Duel.SelectYesNo(tp) and Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD)>0 then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
