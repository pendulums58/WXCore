-- WD09-001 悠久の使者　サシェ・プレンヌ
-- 【自】：あなたのレゾナ１体が場に出たとき、あなたのデッキの一番上のカードをエナゾーンに置く。
-- 【起】《ダウン》：あなたのデッキから＜宇宙＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp,eg)
    local x=eg:GetFirst()
    return x and x:IsType(TYPE_RESONA) and x:GetControler()==tp
  end)
  e1:SetOperation(function(e,tp) Duel.EnaCharge(tp,1) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsUp() end
    Duel.Down(e:GetHandler())
  end)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,aux.ClassFilter(0,RACE_UCHU),1)
  end)
  c:RegisterEffect(e2)
end
