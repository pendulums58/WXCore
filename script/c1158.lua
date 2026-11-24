-- WD07-009 コードメイズ　金字塔
-- 【常】：対戦相手がシグニを配置する場合、可能ならばこのシグニの正面に配置しなければならない。
-- 【起】《ダウン》：あなたのデッキの上からカードを３枚見る。その中から白か黒のシグニ１枚を公開し手札に加え、残りを好きな順番でデッキの一番上に戻す。
-- ライフバースト：あなたのデッキから黒のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 여럿이면 어느 정면인지는 놓는 쪽이 고른다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_MUST_FRONT)
  e1:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(aux.SelfDownCost)
  e2:SetOperation(s.op)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,1)
  end)
  c:RegisterEffect(e3)
end
-- 맞는 시그니가 없으면 3장 모두 돌려놓는다(FAQ 2)
function s.op(e,tp)
  local _,rest=aux.ExcavateToHand(tp,3,function(x) return x:IsSigni() and (x:IsColor(COLOR_WHITE) or x:IsColor(COLOR_BLACK)) end,0,1,true)
  if rest:GetCount()>0 then aux.ToDeckTopInOrder(tp,rest) end
end
