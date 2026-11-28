-- WXK06-004 Ｋアルテマ／メイデン　イオナ
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《アタックフェイズアイコン》エクシード２：このターン、すべてのプレイヤーはシグニを２体までしか場に出すことができない。（すでに場に３体ある場合は２体になるようにシグニをトラッシュに置く）【常】：あなたのセンタールリグがレベル３以上であるかぎり、すべてのプレイヤーはドローフェイズの間にカードを合計１枚までしか引けない。
local s,id=GetID()
function s.initial_effect(c)
  do
    local g=Effect.CreateEffect(c)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Ability(id,1))
    g:SetRange(LOCATION_LRIG)
    g:SetExceedCost(2)
    g:SetTiming(TIMING_ATTACK)
    g:SetOperation(function(e,tp)
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_SIGNI_LIMIT)
      e1:SetTargetRange(1,1)
      e1:SetValue(2)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
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
  e2:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 「合計１枚まで」
  e2:SetDescription(aux.Ability(id,0))
  e2:SetCode(EFFECT_DRAW_PHASE_COUNT)
  e2:SetRange(LOCATION_KEY)
  e2:SetTargetRange(1,1)
  e2:SetValue(1)
  e2:SetCondition(function(e) local tp=e:GetHandlerPlayer() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:GetLevel()>=3 end)
  c:RegisterEffect(e2)
end
