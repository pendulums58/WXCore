-- WXK10-070 魔海の荒嵐　ウェパル
-- 【自】：ガードステップ以外であなたが手札を１枚捨てたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－1000する。
-- 【出】：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－7000する。手札を１枚捨てる。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) if (r&REASON_GUARD)~=0 or (r&REASON_DISCARD)==0 then return false end for x in eg:Iter() do if x:IsPreviousLocation(LOCATION_HAND) and x:GetOwner()==tp then return true end end return false end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-1000)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-7000) end
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else aux.Discard(1-tp,1) end
  end)
  c:RegisterEffect(e9)
end
