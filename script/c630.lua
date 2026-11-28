-- SP38-006 創鍵の巫女 マユ（「ウィクロス 10th Anniversary Book」付録）
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 『【起】エクシード１：このターン、対戦相手の場にあるキーとシグニは能力を失い、新たに得られない。
-- 【起】《アタックフェイズアイコン》エクシード２：対戦相手のシグニゾーンにあるシグニ１体を対象とし、それをトラッシュに置く。対戦相手は自分のデッキの上からカードを３枚見て、その中からシグニを１枚まで場に出し、残りを好きな順番でデッキの一番下に置く。』
-- 【起】このキーを場からルリグトラッシュに置く：あなたはこのターンの次に、追加の１ターンを得る。あなたの次のアタックフェイズとグロウフェイズをスキップする。
local s,id=GetID()
function s.initial_effect(c)
  local g1=Effect.CreateEffect(c)
  g1:SetType(EFFECT_TYPE_IGNITION)
  -- DB에서 이 능력은 【常】 줄에 붙어 있어 따로 문자열로
  g1:SetDescription(aux.Stringid(id,0))
  g1:SetRange(LOCATION_LRIG)
  g1:SetExceedCost(1)
  -- 뒤에 나온 것도(FAQ 4·5)
  g1:SetOperation(function(e,tp)
    -- [の間] 「このターン」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_LOSE_ABILITY)
    e1:SetTargetRange(0,LOCATION_SZONE+LOCATION_KEY)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  local g2=Effect.CreateEffect(c)
  g2:SetType(EFFECT_TYPE_IGNITION)
  g2:SetDescription(aux.Ability(id,1))
  g2:SetRange(LOCATION_LRIG)
  g2:SetTiming(TIMING_ATTACK)
  g2:SetExceedCost(2)
  g2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SIGNI,1,1,nil)
  end)
  -- 빈 시그니 존 어디든, 상대가 정한다(FAQ 1)
  g2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
    local p=1-tp
    local d=Duel.GetDecktopGroup(p,3)
    if d:GetCount()==0 then return end
    Duel.ConfirmCards(p,d)
    local x=Duel.SelectCards(p,d:Filter(Card.IsType,nil,TYPE_SIGNI),0,1):GetFirst()
    if x then Duel.PutOnField(x,p) end
    local rest=d:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(p,rest),false) end
  end)
  for i,g in ipairs({g1,g2}) do
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    -- [の間] 【常】 센터 루리그가 얻는다
    e1:SetDescription(aux.Ability(id,0))
    e1:SetCode(EFFECT_GRANT)
    e1:SetRange(LOCATION_KEY)
    e1:SetTargetRange(LOCATION_LRIG,0)
    e1:SetLabelObject(g)
    c:RegisterEffect(e1)
  end
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_KEY)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  -- 메인 페이즈에 쓰므로 이 턴의 어택 페이즈와 추가 턴의 그로우 페이즈를 건너뛴다(FAQ 2). 어택 페이즈는 두 어택 스텝을 건너뛰는 것으로 근사
  e3:SetOperation(function(e,tp)
    Duel.ExtraTurn(tp)
    local now=Duel.GetTurnCount()
    for _,code in ipairs({EFFECT_SKIP_SIGNI_ATTACK,EFFECT_SKIP_LRIG_ATTACK}) do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(code)
      e1:SetTargetRange(1,0)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SKIP_GROW)
    e2:SetTargetRange(1,0)
    e2:SetCondition(function() return Duel.GetTurnCount()==now+1 end)
    e2:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e2,tp)
  end)
  c:RegisterEffect(e3)
end
