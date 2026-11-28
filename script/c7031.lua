-- WXK10-057 讃の遊　ボブスレー
-- 【自】：このシグニがアタックしたとき、このシグニを場から手札に戻してもよい。そうした場合、あなたのデッキの一番上を公開する。それがシグニの場合、それをアタックしているシグニとしてダウン状態で場に出す。
-- 【起】《ターン１回》《白》他のシグニ１体を場からデッキの一番上に置く：対戦相手のレベル３以下のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 「アタックしているシグニとして」(근사: 다운 상태로 장에)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) or Duel.SendToHand(h)==0 then return end
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if x:IsSigni() then Duel.PutOnField(x,tp,false,true) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetEnaCost("{W}")
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x~=e:GetHandler() end,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return g:GetCount()>0 end
    Duel.SendToDeckPosition(Duel.SelectCards(tp,g,1,1),1)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e2)
end
