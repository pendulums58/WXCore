-- WXK02-001 白滅の巫女　タマヨリヒメ
-- 【自】《ターン１回》：あなたのアタックフェイズの間、あなたのシグニ１体が場から手札に戻ったとき、【エナチャージ１】をする。
-- 【自】《ターン１回》：このルリグがアタックしたとき、《白》を支払ってもよい。そうした場合、あなたのデッキの一番上を公開する。それがシグニの場合、そのシグニを手札に加えるか場に出す。
-- 【起】《ゲーム１回》イノセンス《アタックフェイズアイコン》《コインアイコン》：ターン終了時まで、現在影響している対戦相手のすべての効果は何もしない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_HAND)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) if Duel.GetTurnPlayer()~=tp or Duel.GetPhase()~=PHASE_ATTACK then return false end for x in eg:Iter() do if x:IsType(TYPE_SIGNI) and x:GetOwner()==tp and x:IsPreviousLocation(LOCATION_SZONE) then return true end end return false end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetCountLimit(1)
  e2:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{W}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}"),REASON_COST)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if not x:IsSigni() then return end
    -- 낼 수 없으면 패에(FAQ 2·3)
    if not (Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==1 and Duel.PutOnField(x,tp)) then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetCountLimit(1,true)
  e3:SetCoinCost(1)
  e3:SetOperation(function(e,tp,eg)
    -- [の間] 「ターン終了時まで」 지금 걸려 있는 상대 효과만. 상태·횟수 제한은 그대로(FAQ 5·7)
    Duel.SuppressOpponent()
  end)
  c:RegisterEffect(e3)
end
