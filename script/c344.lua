-- WDK12-009 双撃の記憶　リル
-- 【自】：あなたのメインフェイズ開始時、あなたのデッキの一番上を公開する。それがあなたのセンタールリグと共通する色を持つシグニの場合、それを手札に加える。
-- 【起】このキーを場からルリグトラッシュに置く：《コインアイコン》《コインアイコン》を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_MAIN)
  e1:SetRange(LOCATION_KEY)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  -- 강제. 아니면 덱 위에 그대로(FAQ 3·5). 무색은 공통된 색이 없다(FAQ 6)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,1)
    local tc=g:GetFirst()
    if not tc then return end
    Duel.RevealCards(g)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local col=lc and lc:GetColor() or 0
    if tc:IsSigni() and tc:GetColor()&col~=0 then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e2:SetOperation(function(e,tp)
    Duel.AddCoin(tp,2)
  end)
  c:RegisterEffect(e2)
end
