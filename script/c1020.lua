-- WDK02-009 コード・ピルルク　ＫＥＹ
-- 【常】：あなたのレベル２以上のセンタールリグは以下の能力を得る。
-- 【起】《ターン１回》エクシード１（あなたのルリグの下からカードを１枚ルリグトラッシュに置く）：カードを１枚引く。対戦相手は手札を１枚捨てる。
-- 【起】《ターン１回》《アタックフェイズアイコン》エクシード２（あなたのルリグの下からカードを合計２枚ルリグトラッシュに置く）：対戦相手のシグニ１体を対象とし、それをダウンし凍結する。
-- （凍結されたシグニは次の自分のアップフェイズにアップしない）
local s,id=GetID()
function s.initial_effect(c)
  local g1=Effect.CreateEffect(c)
  g1:SetType(EFFECT_TYPE_IGNITION)
  g1:SetDescription(aux.Ability(id,1))
  g1:SetRange(LOCATION_LRIG)
  g1:SetCountLimit(1)
  g1:SetExceedCost(1)
  -- 상대 패가 없어도 쓸 수 있다(FAQ 3)
  g1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    aux.Discard(1-tp,1)
  end)
  local g2=Effect.CreateEffect(c)
  g2:SetType(EFFECT_TYPE_IGNITION)
  g2:SetDescription(aux.Ability(id,2))
  g2:SetRange(LOCATION_LRIG)
  g2:SetTiming(TIMING_ATTACK)
  g2:SetCountLimit(1)
  g2:SetExceedCost(2)
  g2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  g2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.Down(tc)
      Duel.Freeze(tc)
    end
  end)
  -- [の間] 【常】 레벨 2 이상의 센터 루리그가 얻는다. 그로우해도 계속된다(FAQ 2)
  for _,g in ipairs{g1,g2} do
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_GRANT)
    e1:SetRange(LOCATION_KEY)
    e1:SetTargetRange(LOCATION_LRIG,0)
    e1:SetTarget(function(e,x) return x:GetLevel()>=2 end)
    e1:SetLabelObject(g)
    c:RegisterEffect(e1)
  end
end
