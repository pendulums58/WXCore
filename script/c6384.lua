-- WXK03-008 忘念の巫女　リメンバ
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《アタックフェイズアイコン》エクシード２（あなたのルリグの下からカードを合計２枚ルリグトラッシュに置く）：対戦相手のシグニ１体を対象とし、それをダウンする。
-- 【自】：対戦相手のターン終了時、対戦相手のシグニ１体を対象とし、それを凍結する。（凍結されたシグニは次の自分のアップフェイズにアップしない）
local s,id=GetID()
function s.initial_effect(c)
  do
    local g=Effect.CreateEffect(c)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Ability(id,1))
    g:SetRange(LOCATION_LRIG)
    g:SetExceedCost(2)
    g:SetTiming(TIMING_ATTACK)
    g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    end)
    g:SetOperation(function(e,tp)
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) end
    end)
    local e91=Effect.CreateEffect(c)
    e91:SetType(EFFECT_TYPE_FIELD)
    -- [の間] 【常】 센터 루리그가 얻는다
    e91:SetDescription(aux.Ability(id,0))
    e91:SetCode(EFFECT_GRANT)
    e91:SetRange(LOCATION_KEY)
    e91:SetTargetRange(LOCATION_LRIG,0)
    e91:SetLabelObject(g)
    c:RegisterEffect(e91)
  end
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 키의 능력이라 루리그 효과를 받지 않는 시그니도(FAQ 1)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_TURN_END)
  e2:SetRange(LOCATION_KEY)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.Freeze(tc)
    end
  end)
  c:RegisterEffect(e2)
end
