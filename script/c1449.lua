-- WXK01-028 ママ　ＭＯＤＥ　ＬＯＶＥ
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《ターン１回》エクシード２（あなたのルリグの下からカードを合計２枚ルリグトラッシュに置く）：【エナチャージ２】
-- 【出】《緑》《無》：あなたのデッキの一番上のカードをライフクロスに加える。
-- 【起】《アタックフェイズアイコン》このキーを場からルリグトラッシュに置く：このターン、次に対戦相手のシグニがアタックしたとき、そのアタックを無効にする。
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
      Duel.EnaCharge(tp,2)
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
  e2:SetEnaCost("{G}{C}")
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,1)
    if g:GetCount()>0 then Duel.SendToLife(g) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_KEY)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e3:SetOperation(function(e,tp,eg)
    -- [の間] 「このターン、次に」 대상을 고르지 않는다(FAQ 3)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_NEGATE_NEXT_ATTACK)
    e1:SetTargetRange(0,1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e3)
end
