-- WXK01-021 ミルルン・アド
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《ターン１回》エクシード２（あなたのルリグの下からカードを合計２枚ルリグトラッシュに置く）：あなたの手札からコストの合計が３以下のスペル１枚をコストを支払わずに使用する。（限定条件は無視しない）
-- 【出】：あなたのトラッシュからスペル１枚を対象とし、それを手札に加える。
-- 【起】《スペルカットインアイコン》《青》《無》：スペル１つを対象とし、それの効果を打ち消す。
local s,id=GetID()
function s.initial_effect(c)
  do
    local g=Effect.CreateEffect(c)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Ability(id,1))
    g:SetRange(LOCATION_LRIG)
    g:SetExceedCost(2)
    g:SetCountLimit(1)
    g:SetOperation(function(e,tp)
      -- 한정 조건은 무시하지 않는다. 늘어난 코스트는 낸다(FAQ 2, 근사: 내지 않는다)
      local h=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) and x:GetCostTotal()<=3 and x:IsLimitCond(tp) end,tp,LOCATION_HAND,0,nil)
      if h:GetCount()>0 then Duel.UseFree(Duel.SelectCards(tp,h,1,1):GetFirst(),tp) end
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
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_TRASH,0,1,1,nil)
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
  e3:SetTiming(TIMING_CUTIN)
  e3:SetEnaCost("{U}{C}")
  e3:SetOperation(function(e,tp,eg)
    local sp=Duel.GetCutinSpell()
    if sp then Duel.NegateSpell() end
  end)
  c:RegisterEffect(e3)
end
