-- WDK12-001 メル＝ヴェスパー
-- 【出】：【エナチャージ２】をする。その後、あなたのエナゾーンからシグニを２枚まで対象とし、それらを手札に加える。
-- 【起】《ターン１回》《緑×0》：あなたのトラッシュから対象の＜微菌＞のシグニ１枚を対象のあなたのシグニ１体の【チャーム】にする。
-- 【起】《ゲーム１回》ベルセルク《コインアイコン》：ターン終了時まで、このルリグは「【自】：あなたのシグニ１体が場に出たとき、そのシグニのパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。」を得る。
local s,id=GetID()
s.germ=aux.ClassFilter(0,RACE_BIKIN)  -- ＜微菌＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  -- 【エナチャージ２】으로 놓인 카드도 고른다(FAQ 1)
  e1:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,2)
    local g=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_ENA,0,0,2,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.germ,tp,LOCATION_TRASH,0,1,1,nil)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:GetCharm() end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local ch,host
    for tc in Duel.GetTargets():Iter() do
      if tc:IsLocation(LOCATION_TRASH) then ch=ch or tc elseif tc:IsLocation(LOCATION_SZONE) then host=host or tc end
    end
    if ch and host and ch:IsRelateToEffect(e) and host:IsRelateToEffect(e) and not host:GetCharm() then Duel.Charm(ch,host) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1,true)
  e3:SetCoinCost(1)
  e3:SetOperation(function(e,tp)
    -- [まで] ターン終了時まで このルリグが得る. 바니시는 강제(FAQ 2)
    local h=e:GetHandler()
    local g=Effect.CreateEffect(h)
    g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    g:SetDescription(aux.Ability(id,2))
    g:SetCode(EVENT_ON_PLAY)
    g:SetRange(LOCATION_LRIG)
    g:SetCondition(function(e2,tp2,eg) local x=eg:GetFirst() return x:GetControler()==tp2 and x:IsSigni() end)
    g:SetOperation(function(e2,tp2,eg)
      local p=eg:GetFirst():GetPower()
      local tc=Duel.SelectTarget(tp2,function(x) return x:IsSigni() and x:GetPower()<=p end,tp2,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    end)
    g:SetReset(RESET_PHASE+PHASE_END)
    h:GrantEffect(g)
  end)
  c:RegisterEffect(e3)
end
