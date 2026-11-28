-- PR-K046 ユーリア・シャルデット（カードゲーマーvol.44 付録）
-- 【起】《ターン１回》《無》：スペルのカード名１つを宣言する。次の対戦相手のターンの間、対戦相手は宣言されたカード名のスペルを使用できない。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》《スペルカットインアイコン》このキーを場からルリグトラッシュに置く：対戦相手のシグニ１体を対象とし、それをバニッシュする。その後、対戦相手のトラッシュにあるカード１枚を対象とし、それをゲームから除外する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_KEY)
  e1:SetCountLimit(1)
  e1:SetEnaCost("{C}")
  e1:SetOperation(function(e,tp)
    local cid=Duel.AnnounceCard(tp)
    -- [の間] 次の対戦相手のターンの間
    local now=Duel.GetTurnCount()
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_USE)
    e1:SetTargetRange(0,1)
    e1:SetTarget(function(e2,x) return x:IsType(TYPE_SPELL) and x:IsCardName(cid) end)
    e1:SetCondition(function() return Duel.GetTurnCount()==now+1 end)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK+TIMING_CUTIN)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    local x=Duel.SelectTarget(tp,nil,tp,0,LOCATION_TRASH,1,1,nil):GetFirst()
    if x then Duel.Exclude(x) end
  end)
  c:RegisterEffect(e2)
end
