-- WXK08-056 コードＶＬ　飛鳥ひな
-- 【出】《白》：あなたのデッキの上からカードを３枚見る。その中から１枚を手札に加え、１枚をデッキの一番上に置き、残りをデッキの一番下に置く。
-- 【起】《白》《無》このシグニを場からトラッシュに置く：あなたのシグニ１体を対象とし、あなたの登録者数が１００万人を達成している場合、ターン終了時まで、それは「【自】《ターン１回》：このシグニがアタックしたとき、このシグニをアップする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{W}")
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    Duel.SendToHand(Duel.SelectCards(tp,g,1,1))
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then
      local t1=Duel.SelectCards(tp,rest,1,1)
      local other=rest:Filter(function(y) return not t1:IsContains(y) end,nil)
      if other:GetCount()>0 then Duel.SendToDeckBottom(other,false) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{W}{C}")
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_SZONE) end
    Duel.SendToTrash(e:GetHandler(),REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if not Duel.GetSubscribers(tp)>=100 then return end
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
      g:SetDescription(aux.Stringid(id,0))
      g:SetCode(EVENT_ATTACK)
      g:SetCountLimit(1)
      g:SetOperation(function(e) local h=e:GetHandler() if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end end)
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_GRANT)
      e1:SetLabelObject(g)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
    end
  end)
  c:RegisterEffect(e2)
end
