-- WXK04-006 差し伸べし使　リワト
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《アタックフェイズアイコン》エクシード２：対戦相手のシグニ１体を対象とし、それをバニッシュし、【エナチャージ１】をし、カードを１枚引く。
-- 【起】《ターン１回》《無×0》：ターン終了時まで、あなたのすべての赤と青と緑のシグニはクラスを失い、＜天使＞を得る。
-- 【起】《ターン１回》《赤》《青》《緑》：対戦相手のシグニ１体を対象とし、それをデッキの一番下に置く。
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
      if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
      Duel.EnaCharge(tp,1)
      Duel.Draw(tp,1)
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
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_KEY)
  e2:SetCountLimit(1)
  e2:SetOperation(function(e,tp,eg)
    -- [まで] ターン終了時まで 처리할 때의 시그니
    for x in Duel.GetMatchingGroup(function(y) return y:IsSigni() and (y:IsColor(COLOR_RED) or y:IsColor(COLOR_BLUE) or y:IsColor(COLOR_GREEN)) end,tp,LOCATION_SZONE,0,nil):Iter() do
      -- 「クラスを失い」는 아직(클래스를 잃는 효과가 없다): ＜天使＞를 더하기만
      local e2=Effect.CreateEffect(e:GetHandler())
      e2:SetType(EFFECT_TYPE_SINGLE)
      e2:SetCode(EFFECT_ADD_CLASS)
      e2:SetValue(RACE_TENSHI)
      e2:SetReset(RESET_PHASE+PHASE_END)
      x:RegisterEffect(e2)
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_KEY)
  e3:SetCountLimit(1)
  e3:SetEnaCost("{R}{U}{G}")
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToDeckBottom(tc,false)
    end
  end)
  c:RegisterEffect(e3)
end
