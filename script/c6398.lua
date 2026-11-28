-- WXK03-024 魔界の千夜　シャハラザ
-- 【常】：あなたの手札が０枚であるかぎり、このシグニのパワーは＋2000される。
-- 【自】：各アタックフェイズ開始時、あなたは手札を１枚捨てる。
-- 【自】《ターン２回》：ガードステップ以外であなたが手札を１枚捨てたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－6000する。
-- ライフバースト：手札を１枚捨てる。このターン終了時、カードを２枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()==0 end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 상대 어택 페이즈에도 내가 버린다(FAQ 2)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e2:SetRange(LOCATION_SZONE)
  e2:SetOperation(function(e,tp,eg)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 가드 스텝 이외(가드로 버린 것은 아니다)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_TO_TRASH)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCountLimit(2)
  e3:SetCondition(function(e,tp,eg,ep,ev,re,r) local x=eg:GetFirst() return x:GetOwner()==tp and x:IsPreviousLocation(LOCATION_HAND) and r&REASON_DISCARD~=0 and r&REASON_GUARD==0 end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-6000)
    end
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    aux.Discard(tp,1)
    -- 이 시그니가 없어도 뽑는다
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_TURN_END)
    e1:SetOperation(function() Duel.Draw(tp,2) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e9)
end
