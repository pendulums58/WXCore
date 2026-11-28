-- WXK10-076 コードメイズ　テトラポ
-- 【自】《ターン２回》：あなたの効果１つによって対戦相手のカードが１枚以上デッキに移動したとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－1000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_MOVED_TO_DECK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(2)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) if rp~=tp then return false end for x in eg:Iter() do if x:GetOwner()~=tp then return true end end return false end)
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
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
