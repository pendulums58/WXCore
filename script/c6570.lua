-- WXK05-028 大罠　パーティーバズーカ
-- 【常】：あなたのターンの間、あなたのセンタールリグがレベル４以上であるかぎり、このシグニのパワーは＋4000される。
-- 【出】手札を１枚捨てる：対戦相手のシグニ１体を対象とし、あなたの公開領域にある表向きのシグニであるカードのレベルがすべて奇数の場合、それをバニッシュする。
-- 【起】《ターン１回》《黒×0》：あなたのデッキの上からカードを３枚トラッシュに置く。この方法でトラッシュに置かれたシグニのレベルの合計が７の場合、その中からシグニ１枚を手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local tp=e:GetHandlerPlayer() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return Duel.GetTurnPlayer()==tp and lc and lc:GetLevel()>=4 end)
  e1:SetValue(4000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 공개 영역의 앞면 시그니(근사: 장·에나·트래시)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(aux.DiscardCost(1))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local all=Duel.GetMatchingGroup(function(y) return y:IsType(TYPE_SIGNI) end,tp,LOCATION_SZONE+LOCATION_ENA+LOCATION_TRASH,0,nil)
      if all:Filter(function(x) return x:GetLevel()%2==0 end,nil):GetCount()==0 then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetCountLimit(1)
  e3:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local s=g:Filter(function(x) return x:IsSigni() and x:IsLocation(LOCATION_TRASH) end,nil)
    local n=0
    for x in s:Iter() do n=n+x:GetLevel() end
    if n==7 and s:GetCount()>0 then Duel.SendToHand(Duel.SelectCards(tp,s,1,1)) end
  end)
  c:RegisterEffect(e3)
end
