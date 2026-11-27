-- WX13-005A 白羅星　フルムーン
-- 【出現条件】《メインフェイズアイコン》合計３枚のレゾナではない＜宇宙＞のシグニをあなたの手札と場からトラッシュに置く
-- 【常】：あなたの他のレゾナは対戦相手のシグニの効果を受けない。
-- 【出】：次のあなたのターンまで、対戦相手は各シグニアタックステップにシグニで合計一度しかアタックできない。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,3,aux.NonResonaClass(RACE_UCHU),LOCATION_HAND+LOCATION_SZONE)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x~=e:GetHandler() and x:IsType(TYPE_RESONA) end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsSigni() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    -- [の間] 「次のあなたのターンまで」
    local now=Duel.GetTurnCount()
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SIGNI_ATTACK_ONCE)
    e1:SetTargetRange(0,1)
    e1:SetCondition(function() return Duel.GetTurnPlayer()~=tp or Duel.GetTurnCount()==now end)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e2)
end
