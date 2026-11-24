-- WDK07-Y01 花軍の巫女　ユキ
-- 【出】《白》：あなたの【シード】を好きな枚数対象とし、それらを開花する。（シグニがあるシグニゾーンの【シード】は開花しない）
-- 【起】《ターン１回》手札から＜植物＞のシグニを１枚捨てる：【エナチャージ２】
local s,id=GetID()
s.shoku=aux.ClassFilter(0,RACE_SHOKUBUTSU)  -- ＜植物＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{W}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_SEED,0,0,3,nil)
  end)
  -- 시그니가 있는 존의 것은 개화하지 않는다
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.Bloom(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCost(aux.DiscardCost(1,s.shoku))
  e2:SetOperation(aux.EnaChargeOp(2))
  c:RegisterEffect(e2)
end
