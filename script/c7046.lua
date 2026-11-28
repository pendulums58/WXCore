-- WXK10-072 走英の空力　スリスト
-- 【自】：このシグニがバトルによって対戦相手の凍結状態のシグニ１体をバニッシュしたとき、対戦相手のライフクロス１枚をクラッシュする。
-- 【起】手札を１枚デッキの一番下に置く：対戦相手のすべてのシグニを凍結する。
-- （凍結されたシグニは次の自分のアップフェイズにアップしない）
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをダウンし凍結する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) local x=eg:GetFirst() return ep~=tp and (r&REASON_BATTLE)~=0 and Duel.GetBanisher()==e:GetHandler() end)
  e1:SetOperation(function(e,tp,eg)
    Duel.Crush(1-tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if chk==0 then return h:GetCount()>0 end
    Duel.SendToDeckBottom(Duel.SelectCards(tp,h,1,1),false)
  end)
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.Freeze(g) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.Down(tc)
      Duel.Freeze(tc)
    end
  end)
  c:RegisterEffect(e9)
end
