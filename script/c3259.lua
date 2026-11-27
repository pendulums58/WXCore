-- WX22-038 羅原　Ｍｃ
-- 【出】：あなたのトラッシュに＜原子＞のシグニが７種類以上ある場合、あなたのデッキからコストの合計が２以上のスペル１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    if (function() local seen,n={},0 for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,tp,LOCATION_TRASH,0,nil):Iter() do if not seen[x:GetCode()] then seen[x:GetCode()]=true n=n+1 end end return n end)()<7 then return end
    aux.SearchToHand(tp,function(x) return x:IsType(TYPE_SPELL) and x:GetCostTotal()>=2 end,1)
  end)
  c:RegisterEffect(e1)
end
