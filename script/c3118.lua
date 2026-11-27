-- WX20-024 覚悟の飛将　リョフホウ
-- 【常】：あなたの場に《ライズアイコン》を持つシグニがあるかぎり、このシグニは対戦相手の、ルリグとシグニの効果を受けない。
-- 【自】：このシグニがアタックしたとき、対戦相手にダメージを与える。
-- ライフバースト：あなたのデッキから＜武勇＞のシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_SZONE,0,nil):GetCount()>0 end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and (sc:IsSigni() or sc:IsType(TYPE_LRIG)) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp)
    Duel.Damage(1-tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BUYU)) end,2)
  end)
  c:RegisterEffect(e3)
end
