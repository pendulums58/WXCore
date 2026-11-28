-- WXK09-005 開かれし鍵門　ウトゥルス
-- 【常】：あなたのセンタールリグが＜タウィル＞か＜ウムル＞であるかぎり、それは追加で＜タウィル/ウムル＞を得る。
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《ターン１回》エクシード１：あなたのトラッシュから白か黒のシグニを合計２枚まで対象とし、それらを手札に加える。
-- 【起】《アタックフェイズアイコン》エクシード４：あなたのトラッシュから白か黒のシグニを合計３枚まで対象とし、それらを場に出す。
-- 【出】：あなたのルリグトラッシュから白か黒のキー１枚を対象とし、それをあなたのセンタールリグの下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ADD_LRIG_TYPE)
  e1:SetRange(LOCATION_KEY)
  e1:SetTargetRange(LOCATION_LRIG,0)
  e1:SetTarget(function(e,x) return x:IsLrigType(LRIG_TAWIL) or x:IsLrigType(LRIG_UMR) end)
  e1:SetValue(function(e,x) return x:IsLrigType(LRIG_TAWIL) and LRIG_UMR or LRIG_TAWIL end)
  c:RegisterEffect(e1)
  do
    local g=Effect.CreateEffect(c)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Ability(id,2))
    g:SetRange(LOCATION_LRIG)
    g:SetExceedCost(1)
    g:SetCountLimit(1)
    g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsColor(COLOR_WHITE) or x:IsColor(COLOR_BLACK)) end,tp,LOCATION_TRASH,0,0,2,nil)
    end)
    g:SetOperation(function(e,tp)
      local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
      if g:GetCount()>0 then Duel.SendToHand(g) end
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
    g:SetExceedCost(4)
    g:SetTiming(TIMING_ATTACK)
    g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsColor(COLOR_WHITE) or x:IsColor(COLOR_BLACK)) end,tp,LOCATION_TRASH,0,0,3,nil)
    end)
    g:SetOperation(function(e,tp)
      for x in Duel.GetTargets():Iter() do if x:IsRelateToEffect(e) then Duel.PutOnField(x,tp) end end
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
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_KEY) and (x:IsColor(COLOR_WHITE) or x:IsColor(COLOR_BLACK)) end,tp,LOCATION_LTRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      if lc then Duel.PutUnder(lc,tc) end
    end
  end)
  c:RegisterEffect(e3)
end
