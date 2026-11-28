-- WXEX1-15 再調の彩蝶　アン＝フォース
-- 【自】《ターン１回》：あなたの＜美巧＞のシグニが手札以外から場に出たとき、対戦相手のシグニ１体を対象とし、あなたのターンの場合、《緑》か《白》を支払ってもよい。そうした場合、それを手札に戻す。
-- 【出】：あなたのデッキの上からカードを４枚見る。その中から緑のカード１枚を公開し手札に加え、白のカード１枚をエナゾーンに置き、残りを好きな順番でデッキの一番下に置く。
-- 【起】《ターン１回》《コインアイコン》：【エナチャージ２】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg)
    return eg:Filter(function(x) return x:IsSigni() and x:GetControler()==tp and x:IsClass(0,RACE_BIKOU) and not x:IsPreviousLocation(LOCATION_HAND) end,nil):GetCount()>0
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    if Duel.GetTurnPlayer()~=tp then return end
    local cg,cw=Duel.CanPayEna(tp,"{G}"),Duel.CanPayEna(tp,"{W}")
    if not (cg or cw) or not Duel.SelectYesNo(tp) then return end
    local cost
    if cg and cw then
      cost=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 and "{G}" or "{W}"
    else
      cost=cg and "{G}" or "{W}"
    end
    local pay=Duel.SelectEnaCost(tp,cost)
    if pay:GetCount()>0 and Duel.SendToTrash(pay,REASON_COST)>0 then
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local p1=Duel.SelectCards(tp,g:Filter(function(x) return x:IsColor(COLOR_GREEN) end,nil),1,1)
    if p1:GetCount()>0 then Duel.RevealCards(p1) Duel.SendToHand(p1) end
    local p2=Duel.SelectCards(tp,g:Filter(function(x) return x:IsColor(COLOR_WHITE) and not p1:IsContains(x) end,nil),1,1)
    if p2:GetCount()>0 then Duel.SendToEna(p2) end
    local rest=g:Filter(function(x) return not p1:IsContains(x) and not p2:IsContains(x) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1)
  e3:SetCoinCost(1)
  e3:SetOperation(aux.EnaChargeOp(2))
  c:RegisterEffect(e3)
end
