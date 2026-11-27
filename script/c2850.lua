-- WX16-027 十字の炎槍　サナユキ
-- 【ライズ】あなたの＜武勇＞のシグニ２体の上に置く（どちらかのシグニがあるシグニゾーンに出す）
-- 【出】：あなたのデッキの上からカードを２枚見る。その中から１枚を手札に加え、残りをデッキの一番下に置く。
-- 【起】《ターン１回》《アタックフェイズアイコン》《赤×0》：対戦相手のシグニ１体を対象とし、このシグニの下からカード１枚をトラッシュに置く。そうした場合、それをバニッシュする。
-- ライフバースト：対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- 【ライズ】 「＜武勇＞のシグニ２体の上」는 1체 위로 근사
  aux.AddRise(c,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BUYU)) end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    Duel.SendToHand(Duel.SelectCards(tp,g,1,1))
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,false) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local u=e:GetHandler():GetUnderGroup()
    if u:GetCount()==0 or Duel.SendToTrash(Duel.SelectCards(tp,u,1,1),REASON_EFFECT)==0 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(aux.BanishPowerTarget(12000))
  e3:SetOperation(aux.BanishOp)
  c:RegisterEffect(e3)
end
