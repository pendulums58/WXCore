-- WXK07-039 羅原　Hxg
-- 【自】：このシグニがコストか効果によって場からトラッシュに置かれたとき、あなたの＜原子＞のシグニを２体まで対象とし、ターン終了時まで、それらのパワーをそれぞれ＋5000する。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) and (r&(REASON_EFFECT|REASON_COST))~=0 and (r&REASON_BANISH)==0 end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_GENSHI) end,tp,LOCATION_SZONE,0,0,2,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    for x in Duel.GetTargets():Iter() do if x:IsRelateToEffect(e) then aux.AddPower(e,x,5000) end end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
