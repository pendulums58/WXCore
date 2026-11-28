-- WXK10-028 幻水電　エレクトイール
-- 【自】：あなたのアタックフェイズ開始時、あなたのデッキから緑のシグニ１枚を探してエナゾーンに置き、デッキをシャッフルする。
-- 【起】《ターン１回》《緑》《緑》：このシグニよりパワーの低い対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：あなたのエナゾーンから緑のシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp,eg)
    local x=aux.Search(tp,function(y) return y:IsSigni() and y:IsColor(COLOR_GREEN) end,1):GetFirst()
    if x then Duel.SendToEna(x) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetEnaCost("{G}{G}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local p=e:GetHandler():GetPower()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<p end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.Banish(tc)
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_GREEN) end,tp,LOCATION_ENA,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.SendToHand(tc) else Duel.PutOnField(tc,tp) end
    end
  end)
  c:RegisterEffect(e9)
end
