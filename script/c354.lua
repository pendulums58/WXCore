-- PR-K026 応諾の鍵主　ウムル（ウィクロスカード大全K 付録）
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《ターン１回》《アタックフェイズアイコン》エクシード１：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－7000する。
-- 【起】《ターン１回》《アタックフェイズアイコン》エクシード２：対戦相手のシグニを２体まで対象とし、あなたのデッキの上からカードを９枚トラッシュに置く。この方法でカードが９枚トラッシュに置かれた場合、ターン終了時まで、それらのパワーを合わせて－18000する。この効果では1000単位でしか数字を割り振ることができない。
-- 【起】このキーを場からルリグトラッシュに置く：あなたのトラッシュからシグニ１体を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local g1=Effect.CreateEffect(c)
  g1:SetType(EFFECT_TYPE_IGNITION)
  g1:SetDescription(aux.Ability(id,1))
  g1:SetRange(LOCATION_LRIG)
  g1:SetTiming(TIMING_ATTACK)
  g1:SetCountLimit(1)
  g1:SetExceedCost(1)
  g1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  g1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-7000) end
  end)
  local e91=Effect.CreateEffect(c)
  e91:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 센터 루리그가 얻는다
  e91:SetDescription(aux.Ability(id,0))
  e91:SetCode(EFFECT_GRANT)
  e91:SetRange(LOCATION_KEY)
  e91:SetTargetRange(LOCATION_LRIG,0)
  e91:SetLabelObject(g1)
  c:RegisterEffect(e91)
  local g2=Effect.CreateEffect(c)
  g2:SetType(EFFECT_TYPE_IGNITION)
  g2:SetDescription(aux.Ability(id,2))
  g2:SetRange(LOCATION_LRIG)
  g2:SetTiming(TIMING_ATTACK)
  g2:SetCountLimit(1)
  g2:SetExceedCost(2)
  g2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  g2:SetOperation(function(e,tp)
    local d=Duel.GetDecktopGroup(tp,9)
    if d:GetCount()<9 or Duel.SendToTrash(d,REASON_EFFECT)<9 then return end
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()==0 then return end
    -- 1000 단위로 나눈다
    local first=g:GetFirst()
    local a=g:GetCount()==1 and 18 or Duel.AnnounceNumber(tp,0,18)
    aux.AddPower(e,first,-1000*a)
    for x in g:Iter() do if x~=first then aux.AddPower(e,x,-1000*(18-a)) end end
  end)
  local e92=Effect.CreateEffect(c)
  e92:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 센터 루리그가 얻는다
  e92:SetDescription(aux.Ability(id,0))
  e92:SetCode(EFFECT_GRANT)
  e92:SetRange(LOCATION_KEY)
  e92:SetTargetRange(LOCATION_LRIG,0)
  e92:SetLabelObject(g2)
  c:RegisterEffect(e92)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_KEY)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
end
