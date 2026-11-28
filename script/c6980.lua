-- WXK10-006 劫末の唄鍵　ワールド・エンド
-- 【自】：あなたのアタックフェイズ開始時、あなたの場にあるシグニが持つクラスが＜精元＞を除いて合計２種類以上ある場合、カードを１枚引くか【エナチャージ１】をする。
-- 【起】《コインアイコン》：対戦相手のシグニ１体を対象とし、それをデッキに加えてシャッフルする。
-- 【起】《アタックフェイズアイコン》このキーを場からルリグトラッシュに置き、ルリグデッキからクラフトではないアーツ１枚をルリグトラッシュに置く：あなたのトラッシュからシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_KEY)
  e1:SetCondition(function(e,tp) if Duel.GetTurnPlayer()~=tp then return false end local seen,n={},0 for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do for _,k in ipairs(x:GetClasses()) do if k~=aux.Class(SYS_SEIGEN,0) and not seen[k] then seen[k]=true n=n+1 end end end return n>=2 end)
  e1:SetOperation(function(e,tp,eg)
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetCoinCost(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToDeckShuffle(tc)
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_KEY)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_ARTS) and not x:IsType(TYPE_CRAFT) end,tp,LOCATION_LDECK,0,nil)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) and g:GetCount()>0 end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
    Duel.SendToLrigTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.PutOnField(tc,tp)
    end
  end)
  c:RegisterEffect(e3)
end
