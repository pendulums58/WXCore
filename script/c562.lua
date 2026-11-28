-- SP27-017 太陽の御者　≡ヘリオス≡（セレクターズパック vol.20）
-- 【起】《ダウン》：あなたのトラッシュからレベル４以下の＜天使＞のシグニ１枚を対象とし、それをこのシグニの下に置く。
-- 【起】《アタックフェイズアイコン》このシグニの下からカード２枚をトラッシュに置く：対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) and x:GetLevel()<=4 end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local h=e:GetHandler()
    if tc and tc:IsRelateToEffect(e) and h:IsLocation(LOCATION_SZONE) then Duel.PutUnder(h,tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local u=e:GetHandler():GetUnderGroup()
    if chk==0 then return u:GetCount()>=2 end
    Duel.SendToTrash(Duel.SelectCards(tp,u,2,2),REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
end
