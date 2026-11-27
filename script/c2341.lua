-- WX09-015 極剣　ムラクモ
-- 【自】：このシグニがアタックしたとき、このシグニの正面のシグニ１体を対象とし、カード名に《剣》を含むあなたのアップ状態のシグニ１体をバニッシュしてもよい。そうした場合、それを手札に戻す。
-- 【出】《白》：あなたのデッキからカード名に《剣》を含むシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：あなたのデッキから白のカード１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local f=e:GetHandler():GetFrontCard()
    if f then Duel.SelectTarget(tp,function(x) return x==f end,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local g=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and aux.NameHas(x,"剣") end)(x) and x:IsUp() end,tp,LOCATION_SZONE,0,nil)
    if not (tc and tc:IsRelateToEffect(e)) or g:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    if Duel.Banish(Duel.SelectCards(tp,g,1,1))>0 then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{W}")
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and aux.NameHas(x,"剣") end,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsColor(COLOR_WHITE) end,1)
  end)
  c:RegisterEffect(e3)
end
