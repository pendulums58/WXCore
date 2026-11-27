-- WX04-005 アルテマ/メイデン　イオナ
-- 【グロウ】あなたのライフクロスが１枚以下
-- 【常】：あなたのグロウフェイズをスキップする。
-- 【常】：すべてのプレイヤーはドローフェイズにカードを１枚しか引くことができない。
-- 【常】：すべてのプレイヤーはシグニを１体しか場に出すことができない。
-- （すでに場に２体以上ある場合は１体になるようにシグニをトラッシュに置く）
local s,id=GetID()
function s.initial_effect(c)
  -- 【グロウ】 라이프 클로스가 1장 이하
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=1 end
  end)
  c:RegisterEffect(e0)
  -- [の間] 【常】 셋
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_SKIP_GROW)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(1,0)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EFFECT_DRAW_PHASE_COUNT)
  e2:SetRange(LOCATION_LRIG)
  e2:SetTargetRange(1,1)
  e2:SetValue(1)
  c:RegisterEffect(e2)
  -- 넘으면 턴 플레이어부터 골라 함께 트래시(FAQ 1). 룰을 바꾸는 효과라 「効果を受けない」로 막지 못한다(FAQ 4)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EFFECT_SIGNI_LIMIT)
  e3:SetRange(LOCATION_LRIG)
  e3:SetTargetRange(1,1)
  e3:SetValue(1)
  c:RegisterEffect(e3)
end
