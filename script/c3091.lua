-- WX19-071 幻獣　カッコウ
-- 【自】《ターン１回》：あなたのシグニが【ランサー】によって対戦相手のライフクロスをクラッシュしたとき、あなたのデッキから＜空獣＞か＜地獣＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return ep~=tp and r&REASON_LANCER~=0 end)
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU)) end,1)
  end)
  c:RegisterEffect(e1)
end
