-- WD08-001 混沌の鍵主　ウムル＝フィーラ
-- 【出】：あなたのトラッシュにあるシグニ１枚を対象とし、ターン終了時まで、次にそれの【起】能力を使用する場合、その能力の使用コストは《黒×0》になる。
-- 【起】《ターン１回》《黒×0》：あなたのデッキの上からカードを３枚トラッシュに置く。
-- 【起】《ダウン》：あなたのトラッシュからシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    -- [まで] 트래시에 있는 그 카드에만. 장에 나가면 원래 코스트(FAQ 2)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_FREE_IGNITION)
    e2:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e2)
  end)
  c:RegisterEffect(e1)
  -- 덱이 2장 이하면 전부 놓고 끝, 리프레시는 그 뒤(FAQ 4)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,1))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetDescription(aux.Ability(id,2))
  e4:SetRange(LOCATION_LRIG)
  e4:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsUp() end
    Duel.Down(e:GetHandler())
  end)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e4)
end
