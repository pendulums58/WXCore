-- WXK03-014 エルドラ×ラッキー
-- 【自】《ターン１回》：あなたのライフクロス１枚がクラッシュされたとき、カードを１枚引いてもよい。
-- 【出】：あなたのライフクロスの上からカードを３枚見る。その中から１枚までをトラッシュに置き、残りを好きな順番でライフクロスの一番上に戻す。この方法でライフクロスをトラッシュに置いた場合、あなたのデッキの一番上のカードをライフクロスに加える。
-- 【起】このキーを場からルリグトラッシュに置く：あなたのルリグデッキからコストを支払ってキー１枚を場に出す。そのキーを場に出すためのコストは《コイン×1》減る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_KEY)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e1:SetOperation(function(e,tp,eg)
    if Duel.SelectYesNo(tp) then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    -- 크래시가 아니다: 라이프 버스트·크래시 트리거 없음(FAQ 2·3)
    local g=Duel.GetLifetopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g,0,1)
    local n=x:GetCount()>0 and Duel.SendToTrash(x,REASON_EFFECT) or 0
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_LIFE) end,nil)
    if rest:GetCount()>0 then aux.ToLifeTopInOrder(tp,rest) end
    if n>0 then
      local d=Duel.GetDecktopGroup(tp,1)
      if d:GetCount()>0 then Duel.SendToLife(d) end
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_KEY)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e3:SetOperation(function(e,tp,eg)
    -- 코스트를 내고 낸다. 코인 코스트는 1 줄어든다
    local function ok(x)
      if not x:IsType(TYPE_KEY) then return false end
      return Duel.GetCoin(tp)>=math.max(0,x:GetCoinCost()-1) and Duel.CanPayEna(tp,x:GetEnaCost())
    end
    local g=Duel.GetMatchingGroup(ok,tp,LOCATION_LDECK,0,nil)
    if g:GetCount()==0 then return end
    local k=Duel.SelectCards(tp,g,1,1):GetFirst()
    local cost=k:GetEnaCost()
    if cost~="" then Duel.SendToTrash(Duel.SelectEnaCost(tp,cost),REASON_COST) end
    Duel.AddCoin(tp,-math.max(0,k:GetCoinCost()-1))
    Duel.PutKey(k,tp)
  end)
  c:RegisterEffect(e3)
end
