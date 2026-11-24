-- WD12-015 壱ノ遊　ガチャポ
-- 【自】：あなたのシグニが対戦相手のシグニ１体をバニッシュしたとき、あなたのエナゾーンからレベル１以下のシグニ１枚を対象とし、アップ状態のこのシグニをダウンしてもよい。そうした場合、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep)
    local x=Duel.GetBanisher()
    return ep~=tp and x and x:GetControler()==tp
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=1 end,tp,LOCATION_ENA,0,1,1,nil)
  end)
  -- 다운 상태면 처리하지 못한다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local h,tc=e:GetHandler(),Duel.GetFirstTarget()
    if not (tc and h:IsLocation(LOCATION_SZONE) and h:IsUp() and Duel.SelectYesNo(tp)) then return end
    Duel.Down(h)
    if tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
end
