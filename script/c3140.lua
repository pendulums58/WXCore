-- WX20-052 羅星　ミラ
-- 【常】：あなたのルリグデッキにあるレゾナは出現条件に追加で《アタックフェイズアイコン》を持つ。
-- 【常】：対戦相手のターンの間、あなたの場に他の＜宇宙＞のシグニがあるかぎり、このシグニは対戦相手のシグニの効果を受けない。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 「レゾナの出現条件に《アタックフェイズアイコン》」는 아직(근사 없음)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.GetTurnPlayer()~=tp and Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_UCHU)) end,tp,LOCATION_SZONE,0,e:GetHandler()):GetCount()>0 end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsSigni() end)
  c:RegisterEffect(e1)
end
