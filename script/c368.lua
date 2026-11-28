-- PR-K044 焔型闘娘　花代＆緑子（ウィクロスマガジン2019 Winter 付録）
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《アタックフェイズアイコン》エクシード２：対戦相手のシグニ１体を対象とし、それをバニッシュし、【エナチャージ１】をする。
-- 【出】：以下の３つから２つまで選ぶ。
-- ①あなたの赤か緑のシグニ１体を対象とし、ターン終了時まで、それは【ダブルクラッシュ】を得る。
-- ②対戦相手のシグニ１体を対象とし、それをエナゾーンに置く。
-- ③あなたのトラッシュから赤か緑のカードを合計２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_IGNITION)
  g:SetDescription(aux.Ability(id,1))
  g:SetRange(LOCATION_LRIG)
  g:SetTiming(TIMING_ATTACK)
  g:SetExceedCost(2)
  g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  g:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    Duel.EnaCharge(tp,1)
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
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    for _,m in ipairs(Duel.SelectModes(tp,0,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do
      if m==0 then
        local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsColor(COLOR_RED) or x:IsColor(COLOR_GREEN)) end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
        if tc then aux.GrantKeyword(e,tc,EFFECT_DOUBLE_CRUSH) end
      elseif m==1 then
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc then Duel.SendToEna(tc) end
      else
        local g=Duel.SelectTarget(tp,function(x) return x:IsColor(COLOR_RED) or x:IsColor(COLOR_GREEN) end,tp,LOCATION_TRASH,0,0,2,nil)
        if g:GetCount()>0 then Duel.SendToHand(g) end
      end
    end
  end)
  c:RegisterEffect(e2)
end
