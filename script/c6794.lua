-- WXK08-005 ぶりっつあーや！
-- アタックフェイズの間、あなたのセンタールリグのレベルが対戦相手のセンタールリグより低いかぎり、このキーは《アタックフェイズアイコン》を得る。
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《スペルカットインアイコン》エクシード１：スペル１つを対象とし、それの効果を打ち消す。
-- 【起】《アタックフェイズアイコン》エクシード２：対戦相手のシグニ１体を対象とし、それをダウンし凍結する。
-- 【出】：対戦相手のシグニ１体を対象とし、それをデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  -- 「アタックフェイズの間…このキーは《アタックフェイズアイコン》を得る」(어택 페이즈에 키를 쓸 수 있다)는 아직
  do
    local g=Effect.CreateEffect(c)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Ability(id,2))
    g:SetRange(LOCATION_LRIG)
    g:SetExceedCost(1)
    g:SetTiming(TIMING_CUTIN)
    g:SetOperation(function(e,tp)
      local sp=Duel.GetCutinSpell()
      if sp then Duel.NegateSpell() end
    end)
    local e91=Effect.CreateEffect(c)
    e91:SetType(EFFECT_TYPE_FIELD)
    -- [の間] 【常】 센터 루리그가 얻는다
    e91:SetDescription(aux.Ability(id,1))
    e91:SetCode(EFFECT_GRANT)
    e91:SetRange(LOCATION_KEY)
    e91:SetTargetRange(LOCATION_LRIG,0)
    e91:SetLabelObject(g)
    c:RegisterEffect(e91)
  end
  do
    local g=Effect.CreateEffect(c)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Ability(id,3))
    g:SetRange(LOCATION_LRIG)
    g:SetExceedCost(2)
    g:SetTiming(TIMING_ATTACK)
    g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    end)
    g:SetOperation(function(e,tp)
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) Duel.Freeze(tc) end
    end)
    local e92=Effect.CreateEffect(c)
    e92:SetType(EFFECT_TYPE_FIELD)
    -- [の間] 【常】 센터 루리그가 얻는다
    e92:SetDescription(aux.Ability(id,1))
    e92:SetCode(EFFECT_GRANT)
    e92:SetRange(LOCATION_KEY)
    e92:SetTargetRange(LOCATION_LRIG,0)
    e92:SetLabelObject(g)
    c:RegisterEffect(e92)
  end
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,4))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToDeckPosition(tc,1)
    end
  end)
  c:RegisterEffect(e3)
end
