-- WXK10-015 サポーター　鈴原るる
-- あなたのセンタールリグが＜にじさんじ＞の場合、このキーを場に出すためのコストは《コインアイコン×0》になる。
-- 【常】：あなたが《赤》か《青》を支払う際、代わりに《白》を支払ってもよい。
-- 【起】《ターン１回》手札を１枚捨てる：対戦相手のレベル２以下のシグニ１体を対象とし、それを手札に戻す。
-- 【起】《アタックフェイズアイコン》このキーを場からルリグトラッシュに置く：対戦相手のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  -- 「＜にじさんじ＞の場合…コストは《コインアイコン×0》」는 아직
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 「《赤》か《青》を支払う際、代わりに《白》」(근사: 에나의 백색 카드가 적·청으로도 낸다)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_ADD_PAY_COLOR)
  e1:SetRange(LOCATION_KEY)
  e1:SetTargetRange(LOCATION_ENA,0)
  e1:SetTarget(function(e,x) return x:IsColor(COLOR_WHITE) end)
  e1:SetValue(COLOR_RED|COLOR_BLUE)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_KEY)
  e2:SetCountLimit(1)
  e2:SetCost(aux.DiscardCost(1))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=2 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_KEY)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e3)
end
