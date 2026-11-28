-- WXEX1-45 相英の理論　アインシュタイン
-- 【起】英知＝９《ターン１回》《緑×0》：対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
-- 【常】英知＝１１：あなたの＜英知＞のシグニは対戦相手のルリグの効果を受けない。
-- 【出】《緑》：あなたのデッキからレベルの合計が５以下になるように＜英知＞のシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：対戦相手のシグニを、レベルの合計が４になるように２体まで対象とし、それらをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(aux.EichiCon(9))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_IMMUNE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetCondition(aux.EichiCon(11))
  e2:SetTarget(function(e,x) return x:IsSigni() and x:IsClass(0,RACE_EICHI) end)
  e2:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc and sc:IsType(TYPE_LRIG) end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{G}")
  e3:SetOperation(function(e,tp)
    local d=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil)
    Duel.ConfirmCards(tp,d)
    Duel.SetSelectCheck(function(g)
      local sum=0
      for x in g:Iter() do sum=sum+x:GetLevel() end
      return sum<=5
    end)
    local pick=Duel.SelectCards(tp,d:Filter(aux.ClassFilter(0,RACE_EICHI),nil),0,2)
    if pick:GetCount()>0 then Duel.RevealCards(pick) Duel.SendToHand(pick) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetSelectCheck(function(g)
      if g:GetCount()==0 then return true end
      local sum=0
      for x in g:Iter() do sum=sum+x:GetLevel() end
      return sum==4
    end)
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e9:SetOperation(aux.BanishOp)
  c:RegisterEffect(e9)
end
